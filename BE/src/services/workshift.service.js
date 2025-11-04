const { Op } = require('sequelize');
const { Workshift, Emp } = require('../models');

function assertRange(start_min, end_min) {
  if (!(Number.isInteger(start_min) && Number.isInteger(end_min))) {
    const e = new Error('start_min/end_min must be integer minutes'); e.status = 400; throw e;
  }
  if (end_min <= start_min) {
    const e = new Error('end_min must be greater than start_min'); e.status = 400; throw e;
  }
  if (start_min < 0 || end_min > 24*60) {
    const e = new Error('Range must be within 00:00–24:00'); e.status = 400; throw e;
  }
}

async function list({ mechanicId, dateFrom, dateTo }) {
  const where = {};
  if (mechanicId) where.mechanic_id = mechanicId;
  if (dateFrom && dateTo) where.work_date = { [Op.between]: [dateFrom, dateTo] };
  else if (dateFrom) where.work_date = { [Op.gte]: dateFrom };
  else if (dateTo) where.work_date = { [Op.lte]: dateTo };
  return Workshift.findAll({ where, order: [['work_date','ASC'], ['start_min','ASC']] });
}

async function create({ mechanic_id, work_date, start_min, end_min, step_min = 15 }) {
  // kiểm tra thợ
  const mech = await Emp.findByPk(mechanic_id);
  if (!mech) { const e = new Error('Mechanic not found'); e.status = 404; throw e; }

  assertRange(start_min, end_min);
  if (!Number.isInteger(step_min) || step_min <= 0 || step_min > 120) {
    const e = new Error('step_min must be 1..120'); e.status = 400; throw e;
  }

  // (tùy chọn) chống trùng ca trong cùng ngày cho cùng thợ
  const overlaps = await Workshift.findOne({
    where: {
      mechanic_id, work_date,
      start_min: { [Op.lt]: end_min },
      end_min:   { [Op.gt]: start_min }
    }
  });
  if (overlaps) { const e = new Error('Workshift overlaps existing shift'); e.status = 409; e.code='SHIFT_OVERLAP'; throw e; }

  return Workshift.create({ mechanic_id, work_date, start_min, end_min, step_min });
}

async function update(id, patch) {
  const ws = await Workshift.findByPk(id);
  if (!ws) { const e = new Error('Workshift not found'); e.status = 404; throw e; }

  const next = {
    mechanic_id: patch.mechanic_id ?? ws.mechanic_id,
    work_date:   patch.work_date ?? ws.work_date,
    start_min:   patch.start_min ?? ws.start_min,
    end_min:     patch.end_min ?? ws.end_min,
    step_min:    patch.step_min ?? ws.step_min
  };
  assertRange(next.start_min, next.end_min);

  // chống trùng với ca khác (exclude self)
  const overlaps = await Workshift.findOne({
    where: {
      id: { [Op.ne]: ws.id },
      mechanic_id: next.mechanic_id,
      work_date: next.work_date,
      start_min: { [Op.lt]: next.end_min },
      end_min:   { [Op.gt]: next.start_min }
    }
  });
  if (overlaps) { const e = new Error('Workshift overlaps existing shift'); e.status = 409; e.code='SHIFT_OVERLAP'; throw e; }

  await ws.update(next);
  return ws;
}

async function remove(id) {
  const rows = await Workshift.destroy({ where: { id } });
  if (!rows) { const e = new Error('Workshift not found'); e.status = 404; throw e; }
  return { ok: true };
}

module.exports = { list, create, update, remove };
