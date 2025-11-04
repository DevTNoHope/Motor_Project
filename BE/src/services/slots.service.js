const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
dayjs.extend(utc);
const { Op } = require('sequelize');

const { Emp, Booking, Service, Workshift } = require('../models');

const DIAGNOSIS_PLACEHOLDER_MIN = 30;
const BLOCK_STATUSES = ['PENDING','APPROVED','IN_DIAGNOSIS','IN_PROGRESS'];

async function loadServices(serviceIds) {
  if (!serviceIds || !serviceIds.length) return [];
  return Service.findAll({ where: { id: { [Op.in]: serviceIds }, is_active: true } });
}
function calcDuration(services) {
  let quick = 0; let hasRepair = false;
  for (const s of services) {
    if (s.type === 'QUICK') quick += (s.default_duration_min || 0);
    if (s.type === 'REPAIR') hasRepair = true;
  }
  return quick + (hasRepair ? DIAGNOSIS_PLACEHOLDER_MIN : 0);
}

// lấy ca làm việc theo ngày (UTC ngày đó)
async function getWorkshifts({ mechanicId, date }) {
  const where = { work_date: date };
  if (mechanicId) where.mechanic_id = mechanicId;
  return Workshift.findAll({ where, order: [['mechanic_id','ASC'],['start_min','ASC']] });
}

async function getBusyRanges(mechanicId, dayStart, dayEnd) {
  const rows = await Booking.findAll({
    where: {
      mechanic_id: mechanicId,
      status: { [Op.in]: BLOCK_STATUSES },
      start_dt: { [Op.lt]: dayEnd.toDate() },
      end_dt:   { [Op.gt]: dayStart.toDate() }
    },
    attributes: ['start_dt','end_dt']
  });
  return rows.map(r => ({
    start: dayjs.utc(r.start_dt),
    end: r.end_dt ? dayjs.utc(r.end_dt) : dayjs.utc(r.start_dt).add(60,'minute')
  }));
}

function canPlaceSlot(start, durationMin, busy) {
  const end = start.add(durationMin, 'minute');
  for (const b of busy) {
    if (start.isBefore(b.end) && dayjs(b.start).isBefore(end)) return false;
  }
  return true;
}

function* iterateShiftSlots(dayStartUtc, { start_min, end_min, step_min }, durationMin) {
  // tạo các slot trong [start_min, end_min] theo step_min, đủ durationMin
  for (let m = start_min; m + durationMin <= end_min; m += step_min) {
    yield dayStartUtc.add(m, 'minute');
  }
}

async function slots({ mechanicId, date, serviceIds }) {
  if (!date) { const e = new Error('date required'); e.status = 400; throw e; }
  const dayStart = dayjs.utc(`${date}T00:00:00Z`);
  const dayEnd   = dayStart.add(1, 'day');

  const services = await loadServices(serviceIds || []);
  const durationMin = calcDuration(services);

  // lấy tất cả ca làm việc (1 thợ hoặc tất cả)
  const shifts = await getWorkshifts({ mechanicId, date });

  // nếu cần cho tất cả thợ mà không có ca nào -> rỗng
  if (!mechanicId && shifts.length === 0) return { durationMin, slots: [] };

  // build slots theo từng ca
  const output = [];

  if (mechanicId) {
    // một thợ: trả các slot {start,end,mechanicId}
    const busy = await getBusyRanges(mechanicId, dayStart, dayEnd);
    for (const shift of shifts) {
      for (const start of iterateShiftSlots(dayStart, shift, durationMin)) {
        if (canPlaceSlot(start, durationMin, busy)) {
          output.push({
            start: start.toISOString(),
            end: start.add(durationMin,'minute').toISOString(),
            mechanicId
          });
        }
      }
    }
    return { durationMin, slots: output };
  }

  // bất kỳ thợ: trả slot khi có ÍT NHẤT 1 thợ rảnh, kèm danh sách thợ rảnh
  // gom shifts theo mechanic để đỡ fetch busy nhiều lần
  const mechIds = [...new Set(shifts.map(s => s.mechanic_id))];

  // build busy cache theo thợ
  const busyMap = {};
  for (const id of mechIds) busyMap[id] = await getBusyRanges(id, dayStart, dayEnd);

  // để tránh nhân đôi slot (nhiều thợ cùng rảnh cùng thời điểm), ta duyệt từng shift, ghi map theo start ISO
  const slotMap = new Map(); // key: startISO, value: { start, end, freeMechanics:Set }
  for (const shift of shifts) {
    for (const start of iterateShiftSlots(dayStart, shift, durationMin)) {
      const free = canPlaceSlot(start, durationMin, busyMap[shift.mechanic_id]);
      if (!free) continue;
      const startISO = start.toISOString();
      const endISO = start.add(durationMin,'minute').toISOString();
      if (!slotMap.has(startISO)) slotMap.set(startISO, { start: startISO, end: endISO, freeMechanics: new Set() });
      slotMap.get(startISO).freeMechanics.add(shift.mechanic_id);
    }
  }

  for (const v of slotMap.values()) {
    output.push({ start: v.start, end: v.end, freeMechanics: Array.from(v.freeMechanics) });
  }
  // sắp xếp theo thời gian tăng dần
  output.sort((a,b) => (a.start < b.start ? -1 : 1));

  return { durationMin, slots: output };
}

module.exports = { slots };
