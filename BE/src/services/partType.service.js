const { PartType } = require('../models');

async function getAll() {
  return PartType.findAll();
}

async function create(data) {
  return PartType.create(data);
}

async function update(id, data) {
  const item = await PartType.findByPk(id);
  if (!item) throw Object.assign(new Error('PartType not found'), { status: 404 });
  return item.update(data);
}

async function remove(id) {
  const item = await PartType.findByPk(id);
  if (!item) throw Object.assign(new Error('PartType not found'), { status: 404 });
  await item.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, create, update, remove };
