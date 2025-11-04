const { User, Vehicle } = require('../models');

async function ensureUserByAcc(accId) {
  let u = await User.findOne({ where: { acc_id: accId } });
  if (!u) u = await User.create({ acc_id: accId }); // phòng hờ nếu profile chưa tạo
  return u;
}

async function listMyVehicles(accId) {
  const u = await ensureUserByAcc(accId);
  return Vehicle.findAll({ where: { user_id: u.id }, order: [['id','DESC']] });
}

async function getMyVehicle(accId, id) {
  const u = await ensureUserByAcc(accId);
  const v = await Vehicle.findOne({ where: { id, user_id: u.id } });
  if (!v) throw Object.assign(new Error('Vehicle not found'), { status: 404 });
  return v;
}

async function createMyVehicle(accId, payload) {
  const u = await ensureUserByAcc(accId);
  try {
    const v = await Vehicle.create({ user_id: u.id, ...payload });
    return v;
  } catch (e) {
    if (e.name === 'SequelizeUniqueConstraintError') {
      const err = new Error('Plate already exists for this user');
      err.status = 409; err.code = 'PLATE_EXISTS'; throw err;
    }
    throw e;
  }
}

async function updateMyVehicle(accId, id, payload) {
  const u = await ensureUserByAcc(accId);
  const v = await Vehicle.findOne({ where: { id, user_id: u.id } });
  if (!v) throw Object.assign(new Error('Vehicle not found'), { status: 404 });

  try {
    await v.update(payload);
    return v;
  } catch (e) {
    if (e.name === 'SequelizeUniqueConstraintError') {
      const err = new Error('Plate already exists for this user');
      err.status = 409; err.code = 'PLATE_EXISTS'; throw err;
    }
    throw e;
  }
}

async function deleteMyVehicle(accId, id) {
  const u = await ensureUserByAcc(accId);
  const rows = await Vehicle.destroy({ where: { id, user_id: u.id } });
  if (!rows) throw Object.assign(new Error('Vehicle not found'), { status: 404 });
  return { ok: true };
}

module.exports = { listMyVehicles, getMyVehicle, createMyVehicle, updateMyVehicle, deleteMyVehicle };
