const { Emp: Employee, Acc, Role } = require('../models');
const bcrypt = require('bcryptjs');


async function getAll() {
  return Employee.findAll({
    include: [
      {
        model: Acc,
        include: [{ model: Role, attributes: ['code', 'name'] }],
        attributes: ['id', 'name','email', 'phone', 'gender', 'birth_year', 'avatar_url']
      }
    ]
  });
}

async function getById(id) {
  return Employee.findByPk(id, {
    include: [
      {
        model: Acc,
        include: [{ model: Role, attributes: ['code', 'name'] }],
        attributes: ['id', 'name','email', 'phone', 'gender', 'birth_year', 'avatar_url']
      }
    ]
  });
}

async function create(data) {
  // 1️⃣ Tìm role thợ (MECHANIC)
  const role = await Role.findOne({ where: { code: 'MECHANIC' } });
  if (!role) throw Object.assign(new Error('Role MECHANIC not found'), { status: 500 });

  // 2️⃣ Tạo tài khoản mới cho thợ
  const acc = await Acc.create({
    role_id: role.id,
    email: data.email,
    phone: data.phone,
    name: data.name,
    password_hash: await bcrypt.hash('123456', 10), // mật khẩu mặc định
    gender: 'O',
    birth_year: null,
    avatar_url: data.avatar_url || null
  });

  // 3️⃣ Tạo hồ sơ thợ gắn acc_id
  const emp = await Employee.create({
    acc_id: acc.id,
    skill_tags: data.skill_tags || null,
    hired_at: data.hired_at || null
  });

  return emp;
}

async function update(id, data) {
  const emp = await Employee.findByPk(id, { include: [Acc] });
  if (!emp) throw Object.assign(new Error('Employee not found'), { status: 404 });

  // Cập nhật hồ sơ thợ
  await emp.update({
    skill_tags: data.skill_tags ?? emp.skill_tags,
    hired_at: data.hired_at ?? emp.hired_at
  });

  // Cập nhật tài khoản liên kết
  if (emp.Acc) {
    await emp.Acc.update({
      name: data.name ?? emp.Acc.name,
      email: data.email ?? emp.Acc.email,
      phone: data.phone ?? emp.Acc.phone,
      avatar_url: data.avatar_url ?? emp.Acc.avatar_url // ✅ thêm dòng này
    });
  }

  return emp;
}

async function remove(id) {
  const emp = await Employee.findByPk(id);
  if (!emp) throw Object.assign(new Error('Employee not found'), { status: 404 });
  await emp.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
