const { Op } = require('sequelize');
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
dayjs.extend(utc);

const { Acc, User, Emp, Vehicle, Service, Booking, BookingService, Diagnosis, Part, Inventory, ServicePart, BookingPart, sequelize } = require('../models');
const { isOverlap } = require('../utils/overlap');

// cấu hình
const DIAGNOSIS_PLACEHOLDER_MIN = 30; // slot chẩn đoán cho REPAIR trước khi ước lượng
const BLOCK_STATUSES = ['PENDING','APPROVED','IN_DIAGNOSIS','IN_PROGRESS']; // các trạng thái chặn đặt lịch

async function ensureUserByAcc(accId) {
  let u = await User.findOne({ where: { acc_id: accId } });
  if (!u) u = await User.create({ acc_id: accId });
  return u;
}

async function loadServices(serviceIds) {
  const rows = await Service.findAll({ where: { id: { [Op.in]: serviceIds }, is_active: true } });
  if (rows.length !== serviceIds.length) {
    const has = new Set(rows.map(r => String(r.id)));
    const miss = serviceIds.filter(id => !has.has(String(id)));
    const e = new Error('Some services not found or inactive: ' + miss.join(','));
    e.status = 400; e.code = 'SERVICE_NOT_FOUND'; throw e;
  }
  return rows;
}

function calcInitialDuration(services) {
  let quickMin = 0;
  let hasRepair = false;

  for (const s of services) {
    if (s.type === 'QUICK') {
      if (!s.default_duration_min) {
        const e = new Error(`Service ${s.id} missing default_duration_min`);
        e.status = 400; e.code = 'SERVICE_DURATION_MISSING'; throw e;
      }
      quickMin += s.default_duration_min;
    } else if (s.type === 'REPAIR') {
      hasRepair = true;
    }
  }

  const initialMin = quickMin + (hasRepair ? DIAGNOSIS_PLACEHOLDER_MIN : 0);
  return { initialMin, quickMin, hasRepair };
}

async function checkOverlap(mechanicId, startISO, endISO, ignoreBookingId = null) {
  if (!mechanicId) return; // chọn "bất kỳ" -> chưa cần check
  const start = new Date(startISO);
  const end   = new Date(endISO);

  // lấy các booking của thợ trùng khoảng thời gian và có status chặn
  const rows = await Booking.findAll({
    where: {
      mechanic_id: mechanicId,
      status: { [Op.in]: BLOCK_STATUSES },
      start_dt: { [Op.lt]: end },      // start < end_new
      end_dt:   { [Op.gt]: start }     // end   > start_new
    },
    attributes: ['id','start_dt','end_dt','status']
  });

  // nếu end_dt null (hiếm khi cho REPAIR chưa chẩn đoán), coi như trùng nếu thời gian giao nhau theo start_dt
  for (const b of rows) {
    const bStart = new Date(b.start_dt);
    const bEnd   = b.end_dt ? new Date(b.end_dt) : new Date(bStart.getTime() + 60*60*1000); // fallback 60'
    if (ignoreBookingId && Number(ignoreBookingId) === Number(b.id)) continue;
    if (isOverlap(start, end, bStart, bEnd)) {
      const e = new Error('Mechanic time overlap');
      e.status = 409; e.code = 'OVERLAP_SLOT';
      e.details = { with: b.id, bStart, bEnd };
      throw e;
    }
  }
}

async function createBooking(accId, payload) {
  const { vehicleId, serviceIds, mechanicId = null, start, notesUser } = payload;

  if (!Array.isArray(serviceIds) || serviceIds.length === 0) {
    const e = new Error('serviceIds required'); e.status = 400; throw e;
  }
  if (!start) { const e = new Error('start required'); e.status = 400; throw e; }

  const user = await ensureUserByAcc(accId);

  // kiểm tra xe thuộc về user
  const vehicle = await Vehicle.findOne({ where: { id: vehicleId, user_id: user.id } });
  if (!vehicle) { const e = new Error('Vehicle not found'); e.status = 404; throw e; }

  // kiểm tra mechanic (nếu có)
  if (mechanicId) {
    const mech = await Emp.findOne({ where: { id: mechanicId } });
    if (!mech) { const e = new Error('Mechanic not found'); e.status = 404; throw e; }
  }

  // tính thời lượng ban đầu
  const services = await loadServices(serviceIds);
  const { initialMin, hasRepair } = calcInitialDuration(services);

  const startDt = dayjs.utc(start);
  const endDt   = startDt.add(initialMin, 'minute');

  // chống trùng nếu đã chỉ định thợ
  await checkOverlap(mechanicId, startDt.toISOString(), endDt.toISOString());

  // tạo booking + items (transaction nhẹ)
  const booking = await Booking.create({
    user_id: user.id,
    mechanic_id: mechanicId || null,
    vehicle_id: vehicle.id,
    start_dt: startDt.toDate(),
    end_dt: endDt.toDate(),
    status: 'PENDING',
    notes_user: notesUser || null
  });

  // lưu services snapshot
  for (const s of services) {
    await BookingService.create({
      booking_id: booking.id,
      service_id: s.id,
      qty: 1,
      price_snapshot: s.base_price,
      duration_snapshot_min: s.type === 'QUICK' ? s.default_duration_min : null
    });
  }

  // nếu có REPAIR → sau khi Admin approve, thợ sẽ chuyển `IN_DIAGNOSIS` rồi cập nhật lại `end_dt` dựa trên `labor_est_min`.
  return { id: booking.id, status: booking.status, hasRepair, start_dt: booking.start_dt, end_dt: booking.end_dt };
}

async function listMyBookings(accId) {
  const user = await ensureUserByAcc(accId);
  return Booking.findAll({
    where: { user_id: user.id },
    order: [['id','DESC']],
    include: [{ model: BookingService, include: [Service] }]
  });
}

async function getMyBooking(accId, id) {
  const user = await ensureUserByAcc(accId);
  const b = await Booking.findOne({
    where: { id, user_id: user.id },
    include: [{ model: BookingService, include: [Service] }]
  });
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
  return b;
}

async function cancelMyBooking(accId, id) {
  const user = await ensureUserByAcc(accId);
  const b = await Booking.findOne({ where: { id, user_id: user.id } });
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
  if (['IN_PROGRESS','DONE','CANCELED'].includes(b.status)) {
    const e = new Error('Cannot cancel at this status'); e.status = 400; e.code = 'INVALID_STATE'; throw e;
  }
  b.status = 'CANCELED';
  await b.save();
  return { ok: true };
}

/** Tính tổng phút QUICK đã chọn trong booking */
async function getQuickMinutes(bookingId) {
  const rows = await BookingService.findAll({
    where: { booking_id: bookingId },
    include: [{ model: Service, attributes: ['type','default_duration_min'] }]
  });
  let quickMin = 0;
  let hasRepair = false;
  for (const r of rows) {
    if (r.Service.type === 'QUICK') quickMin += (r.Service.default_duration_min || 0);
    if (r.Service.type === 'REPAIR') hasRepair = true;
  }
  return { quickMin, hasRepair };
}

/** Lấy booking (kèm services) */
async function getBookingById(id) {
  return Booking.findOne({
    where: { id },
    include: [{ model: BookingService, include: [Service] }]
  });
}

/** ADMIN: phê duyệt */
async function adminApprove(bookingId) {
  const b = await getBookingById(bookingId);
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
  if (['CANCELED','DONE'].includes(b.status)) {
    const e = new Error('Cannot approve at this status'); e.status = 400; throw e;
  }
  b.status = 'APPROVED';
  await b.save();
  return b;
}

/** ADMIN: chỉ định thợ (assign) + chống trùng thời gian hiện có của booking */
async function adminAssign(bookingId, mechanicId) {
  const b = await getBookingById(bookingId);
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
  if (['CANCELED','DONE','IN_PROGRESS'].includes(b.status)) {
    const e = new Error('Cannot assign at this status'); e.status = 400; throw e;
  }
  // kiểm tra thợ tồn tại
  const mech = await Emp.findOne({ where: { id: mechanicId } });
  if (!mech) { const e = new Error('Mechanic not found'); e.status = 404; throw e; }

  // thời lượng hiện tại: nếu đã có end_dt -> dùng; nếu null, dùng placeholder
  const { quickMin, hasRepair } = await getQuickMinutes(b.id);
  const start = dayjs.utc(b.start_dt);
  const end = b.end_dt
    ? dayjs.utc(b.end_dt)
    : start.add(quickMin + (hasRepair ? DIAGNOSIS_PLACEHOLDER_MIN : 0), 'minute');

  // chống trùng
  await checkOverlap(mechanicId, start.toISOString(), end.toISOString(), b.id);

  b.mechanic_id = mechanicId;
  await b.save();
  return b;
}

/** MECHANIC: chẩn đoán – ghi phiếu + cập nhật end_dt = start + quickMin + laborEstMin; set status IN_DIAGNOSIS */
async function mechanicDiagnose(bookingId, mechanicAccId, { diagnosisNote, etaMin, laborEstMin, requiredParts }) {
  const b = await getBookingById(bookingId);
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
  if (!b.mechanic_id) { const e = new Error('Booking not assigned'); e.status = 400; throw e; }

  // (khuyến nghị) Chỉ thợ được assign mới được chẩn đoán
  const emp = await Emp.findOne({ where: { acc_id: mechanicAccId } });
  if (!emp || emp.id !== b.mechanic_id) { const e = new Error('Forbidden'); e.status = 403; throw e; }

  if (!['APPROVED','IN_DIAGNOSIS'].includes(b.status)) {
    const e = new Error('Invalid state for diagnosis'); e.status = 400; throw e;
  }

  const { quickMin } = await getQuickMinutes(b.id);
  const start = dayjs.utc(b.start_dt);
  const end = start.add(quickMin + (laborEstMin || 0), 'minute');

  // check overlap với thời lượng thực
  await checkOverlap(b.mechanic_id, start.toISOString(), end.toISOString(), b.id);

  // upsert Diagnosis
  await Diagnosis.upsert({
    booking_id: b.id,
    diagnosis_note: diagnosisNote || '',
    eta_min: etaMin ?? null,
    labor_est_min: laborEstMin ?? null,
    required_parts: requiredParts ?? null,
    created_at: new Date()
  });

  // cập nhật booking
  b.end_dt = end.toDate();
  b.status = 'IN_DIAGNOSIS';
  await b.save();

  return b;
}

// ==== Helpers cho parts & inventory ====

// Gom phụ tùng cần dùng từ QUICK mapping + Diagnosis (REPAIR)
// Trả [{ part_id, qty }]
async function buildPartsNeeded(bookingId) {
  const items = [];

  // QUICK → từ Service_Parts
  const bs = await BookingService.findAll({
    where: { booking_id: bookingId },
    include: [{ model: Service, attributes: ['id','type'] }]
  });
  const quickIds = bs.filter(x => x.Service.type === 'QUICK').map(x => x.service_id);
  if (quickIds.length) {
    const maps = await ServicePart.findAll({ where: { service_id: { [Op.in]: quickIds } } });
    for (const m of maps) items.push({ part_id: m.part_id, qty: m.qty_per_service * 1 });
  }

  // REPAIR → từ Diagnosis.required_parts (JSON)
  const diag = await Diagnosis.findOne({ where: { booking_id: bookingId } });
  if (diag && Array.isArray(diag.required_parts)) {
    for (const rp of diag.required_parts) {
      const pid = Number(rp.partId ?? rp.part_id);
      const q = Number(rp.qty ?? rp.quantity ?? 0);
      if (pid && q > 0) items.push({ part_id: pid, qty: q });
    }
  }

  // gộp theo part_id
  const merged = new Map();
  for (const it of items) merged.set(it.part_id, (merged.get(it.part_id) || 0) + it.qty);
  return Array.from(merged, ([part_id, qty]) => ({ part_id, qty }));
}

// Tạo snapshot Booking_Parts nếu chưa có
async function ensureBookingPartsSnapshot(bookingId, neededParts, t) {
  const existing = await BookingPart.findAll({ where: { booking_id: bookingId }, transaction: t });
  if (existing.length) return existing; // đã có -> dùng lại (idempotent)

  const parts = await Part.findAll({ where: { id: { [Op.in]: neededParts.map(p => p.part_id) } }, transaction: t });
  const priceMap = new Map(parts.map(p => [Number(p.id), Number(p.price || 0)]));

  const rows = [];
  for (const np of neededParts) {
    rows.push(await BookingPart.create({
      booking_id: bookingId,
      part_id: np.part_id,
      qty: np.qty,
      price_snapshot: priceMap.get(Number(np.part_id)) ?? null
    }, { transaction: t }));
  }
  return rows;
}

// Trừ kho theo danh sách Booking_Parts (atomic). Ném OUT_OF_STOCK nếu thiếu.
async function deductInventory(bookingParts, t) {
  for (const bp of bookingParts) {
    const inv = await Inventory.findOne({ where: { part_id: bp.part_id }, lock: t.LOCK.UPDATE, transaction: t });
    const current = Number(inv?.qty || 0);
    if (current < bp.qty) {
      const e = new Error(`Out of stock for part ${bp.part_id}`);
      e.status = 409; e.code = 'OUT_OF_STOCK';
      e.details = { part_id: bp.part_id, needed: bp.qty, available: current };
      throw e;
    }
    await inv.update({ qty: current - bp.qty }, { transaction: t });
  }
}

// Tính tổng tiền (dịch vụ + phụ tùng) từ snapshots
async function computeTotals(bookingId, t) {
  const services = await BookingService.findAll({ where: { booking_id: bookingId }, transaction: t });
  const parts    = await BookingPart.findAll({ where: { booking_id: bookingId }, transaction: t });

  const total_service_amount = services.reduce((sum, s) =>
    sum + Number(s.price_snapshot || 0) * Number(s.qty || 1), 0);

  const total_parts_amount = parts.reduce((sum, p) =>
    sum + Number(p.price_snapshot || 0) * Number(p.qty || 0), 0);

  return {
    total_service_amount: Number(total_service_amount.toFixed(2)),
    total_parts_amount:   Number(total_parts_amount.toFixed(2)),
    total_amount:         Number((total_service_amount + total_parts_amount).toFixed(2))
  };
}

/** MECHANIC: bắt đầu làm – chuyển IN_PROGRESS (QUICK có thể start ngay sau APPROVED; REPAIR nên đã có IN_DIAGNOSIS trước) */
async function mechanicStart(bookingId, mechanicAccId) {
  const t = await sequelize.transaction();
  try {
    const b = await Booking.findOne({ where: { id: bookingId }, transaction: t, lock: t.LOCK.UPDATE });
    if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
    if (!b.mechanic_id) { const e = new Error('Booking not assigned'); e.status = 400; throw e; }
    if (!['APPROVED','IN_DIAGNOSIS','IN_PROGRESS'].includes(b.status)) {
      const e = new Error('Invalid state for start'); e.status = 400; throw e;
    }

    // chống trùng một lần nữa tại thời điểm start
    const { quickMin, hasRepair } = await getQuickMinutes(b.id);
    const start = dayjs.utc(b.start_dt);
    const end = b.end_dt
      ? dayjs.utc(b.end_dt)
      : start.add(quickMin + (hasRepair ? DIAGNOSIS_PLACEHOLDER_MIN : 0), 'minute');

    await checkOverlap(b.mechanic_id, start.toISOString(), end.toISOString(), b.id);

    // Nếu chưa trừ kho -> trừ ngay bây giờ (idempotent qua cờ stock_deducted)
    if (!b.stock_deducted) {
      const needed = await buildPartsNeeded(b.id);
      const bookingParts = await ensureBookingPartsSnapshot(b.id, needed, t);
      await deductInventory(bookingParts, t);
      b.stock_deducted = 1;
    }

    // set trạng thái
    b.status = 'IN_PROGRESS';
    await b.save({ transaction: t });

    await t.commit();
    return b;
  } catch (e) {
    await t.rollback();
    throw e;
  }
}


/** MECHANIC: hoàn thành – DONE */
async function mechanicComplete(bookingId, mechanicAccId) {
  const t = await sequelize.transaction();
  try {
    const b = await Booking.findOne({ where: { id: bookingId }, transaction: t, lock: t.LOCK.UPDATE });
    if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }
    if (b.status !== 'IN_PROGRESS') {
      const e = new Error('Invalid state for complete'); e.status = 400; throw e;
    }

    // Tính tổng tiền từ snapshots (dịch vụ đã snapshot khi tạo, phụ tùng snapshot khi start)
    const totals = await computeTotals(b.id, t);

    b.status = 'DONE';
    if ('total_service_amount' in b) {
      b.total_service_amount = totals.total_service_amount;
      b.total_parts_amount   = totals.total_parts_amount;
      b.total_amount         = totals.total_amount;
    }
    await b.save({ transaction: t });

    await t.commit();
    return { ok:true, id:b.id, status:b.status, ...totals };
  } catch (e) {
    await t.rollback();
    throw e;
  }
}

async function adminListBookings({ status, dateFrom, dateTo, mechanicId, page=1, size=20 }) {
  const where = {};
  if (status) where.status = status;
  if (mechanicId) where.mechanic_id = mechanicId;
  if (dateFrom || dateTo) {
    where.start_dt = {};
    if (dateFrom) where.start_dt[Op.gte] = new Date(dateFrom);
    if (dateTo)   where.start_dt[Op.lte] = new Date(dateTo);
  }

  const offset = (Math.max(1, +page) - 1) * Math.max(1, +size);
  const limit  = Math.max(1, +size);

  const { rows, count } = await Booking.findAndCountAll({
    where,
    include: [
      // User + Acc (lấy name/phone từ Accs)
      {
        model: User,
        attributes: ['id','acc_id'],
        include: [{ model: Acc, attributes: ['name','phone'] }]
      },
      // Mechanic (Employee) + Acc (lấy name)
      {
        model: Emp,
        attributes: ['id','acc_id'],
        include: [{ model: Acc, attributes: ['name'] }]
      },
      // Vehicle: dùng plate_no, model, brand...
      {
        model: Vehicle,
        attributes: ['id','plate_no','brand','model']
      },
      // BookingServices + Service
      {
        model: BookingService,
        attributes: ['id','qty','price_snapshot','duration_snapshot_min'],
        include: [{ model: Service, attributes: ['id','name','type'] }]
      }
    ],
    order: [['start_dt', 'ASC']],
    offset, limit
  });

  return {
    items: rows,
    page: +page, size: +size,
    total: count, pages: Math.ceil(count/limit)
  };
}

async function adminCancel(bookingId, reason) {
  const b = await Booking.findByPk(bookingId);
  if (!b) { const e = new Error('Booking not found'); e.status = 404; throw e; }

  // chỉ cho hủy khi chưa vào IN_PROGRESS/DONE
  if (['IN_PROGRESS','DONE','CANCELED'].includes(b.status)) {
    const e = new Error('Booking cannot be canceled in current state'); e.status = 400; throw e;
  }
  // nếu đã trừ kho (trường hợp hiếm), chặn hủy để tránh âm kho
  if (b.stock_deducted) {
    const e = new Error('Cannot cancel: inventory already deducted'); e.status = 409; e.code='ALREADY_DEDUCTED'; throw e;
  }

  b.status = 'CANCELED';
  if (reason) b.notes_mechanic = `[ADMIN CANCEL] ${reason}`;
  await b.save();

  return { ok: true, id: b.id, status: b.status };
}

module.exports = { createBooking, listMyBookings, getMyBooking, cancelMyBooking, checkOverlap, adminApprove,
  adminAssign,
  mechanicDiagnose,
  mechanicStart,
  mechanicComplete,
  getQuickMinutes, adminListBookings, adminCancel };