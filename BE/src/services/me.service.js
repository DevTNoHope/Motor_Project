const { Acc, Role, User, Emp } = require('../models');
const { Op } = require('sequelize');

const ACC_FIELDS = ['name','gender','birth_year','avatar_url', 'email', 'phone']; // chỉ cho update các field này

async function getProfile(accId) {
  const acc = await Acc.findOne({
    where: { id: accId },
    include: [{ model: Role, attributes: ['code','name'] }]
  });
  if (!acc) throw Object.assign(new Error('Account not found'), { status: 404 });

  const roleCode = acc.Role.code;

  let profile = null;
  if (roleCode === 'USER') {
    profile = await User.findOne({ where: { acc_id: acc.id } });
  } else if (roleCode === 'MECHANIC') {
    profile = await Emp.findOne({ where: { acc_id: acc.id } });
  }

  return {
    account: {
      id: acc.id, email: acc.email, phone: acc.phone,
      name: acc.name, gender: acc.gender, birth_year: acc.birth_year, avatar_url: acc.avatar_url
    },
    role: roleCode,
    profile // có thể null nếu chưa tạo hồ sơ thợ/user tương ứng
  };
}

async function updateProfile(accId, payload) {
  // tách dữ liệu cập nhật account vs profile
  const accPatch = {};
  ACC_FIELDS.forEach(k => { if (payload[k] !== undefined) accPatch[k] = payload[k]; });

   if (payload.email) {
    const exists = await Acc.count({ where: { email: payload.email, id: { [Op.ne]: accId } } });
    if (exists) {
      const err = new Error('Email already in use');
      err.status = 409; err.code = 'EMAIL_TAKEN';
      throw err;
    }
  }
  if (payload.phone) {
    const exists = await Acc.count({ where: { phone: payload.phone, id: { [Op.ne]: accId } } });
    if (exists) {
      const err = new Error('Phone already in use');
      err.status = 409; err.code = 'PHONE_TAKEN';
      throw err;
    }
  }
  // cập nhật Accs
  if (Object.keys(accPatch).length) {
    await Acc.update(accPatch, { where: { id: accId } });
  }

  // xem role để cập nhật profile Users/Employees
  const acc = await Acc.findOne({
    where: { id: accId },
    include: [{ model: Role, attributes: ['code'] }]
  });
  if (!acc) throw Object.assign(new Error('Account not found'), { status: 404 });

  const roleCode = acc.Role.code;

  if (roleCode === 'USER') {
    // cho phép user cập nhật địa chỉ, ghi chú
    const userPatch = {};
    if (payload.address !== undefined) userPatch.address = payload.address;
    if (payload.note !== undefined) userPatch.note = payload.note;

    if (Object.keys(userPatch).length) {
      const [count] = await User.update(userPatch, { where: { acc_id: accId } });
    }
  } else if (roleCode === 'MECHANIC') {
    // cho phép thợ cập nhật skill_tags, hired_at (optional)
    const empPatch = {};
    if (payload.skill_tags !== undefined) empPatch.skill_tags = payload.skill_tags;
    if (payload.hired_at !== undefined) empPatch.hired_at = payload.hired_at;

    if (Object.keys(empPatch).length) {
      const [count] = await Emp.update(empPatch, { where: { acc_id: accId } });
    }
  }

  // trả lại hồ sơ mới
  return getProfile(accId);
}

module.exports = { getProfile, updateProfile };
