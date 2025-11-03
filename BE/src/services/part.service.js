const { Part, PartType } = require('../models');

async function getAll() {
  return Part.findAll({ include: [{ model: PartType }] });
}

async function getById(id) {
  const part = await Part.findByPk(id, { include: [{ model: PartType }] });
  if (!part) throw Object.assign(new Error('Part not found'), { status: 404 });
  return part;
}

async function create(data) {
  return Part.create(data);
}

async function update(id, data) {
  const part = await Part.findByPk(id);
  if (!part) throw Object.assign(new Error('Part not found'), { status: 404 });
  return part.update(data);
}

async function remove(id) {
  const part = await Part.findByPk(id);
  if (!part) throw Object.assign(new Error('Part not found'), { status: 404 });
  await part.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
