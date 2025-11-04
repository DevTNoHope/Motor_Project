const { Emp: Employee, Acc, Role } = require('../models');


async function getAll() {
  return Employee.findAll({
    include: [
      {
        model: Acc,
        include: [{ model: Role, attributes: ['code', 'name'] }],
        attributes: ['id', 'name', 'gender', 'birth_year', 'avatar_url']
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
        attributes: ['id', 'name', 'gender', 'birth_year', 'avatar_url']
      }
    ]
  });
}

async function create(data) {
  return Employee.create(data);
}

async function update(id, data) {
  const emp = await Employee.findByPk(id);
  if (!emp) throw Object.assign(new Error('Employee not found'), { status: 404 });
  return emp.update(data);
}

async function remove(id) {
  const emp = await Employee.findByPk(id);
  if (!emp) throw Object.assign(new Error('Employee not found'), { status: 404 });
  await emp.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
