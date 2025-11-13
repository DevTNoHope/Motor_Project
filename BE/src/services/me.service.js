const { Acc, Role, User, Emp } = require('../models');

const ACC_FIELDS = ['name','gender','birth_year','avatar_url']; // chỉ cho update các field này

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
      if (!count) {
        // nếu vì lý do nào đó chưa có profile, tạo mới
        await User.create({ acc_id: accId, ...userPatch });
      }
    }
  } else if (roleCode === 'MECHANIC') {
    // cho phép thợ cập nhật skill_tags, hired_at (optional)
    const empPatch = {};
    if (payload.skill_tags !== undefined) empPatch.skill_tags = payload.skill_tags;
    if (payload.hired_at !== undefined) empPatch.hired_at = payload.hired_at;

    if (Object.keys(empPatch).length) {
      const [count] = await Emp.update(empPatch, { where: { acc_id: accId } });
      // if (!count) {
      //   await Emp.create({ acc_id: accId, ...empPatch });
      // }
    }
  }

  // trả lại hồ sơ mới
  return getProfile(accId);
}

module.exports = { getProfile, updateProfile };
