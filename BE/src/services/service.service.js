const { Service } = require('../models');

async function getAll() {
  return Service.findAll({ order: [['id', 'ASC']] });
}

async function getById(id) {
  const service = await Service.findByPk(id);
  if (!service) throw Object.assign(new Error('Service not found'), { status: 404 });
  return service;
}

async function create(data) {
  return Service.create(data);
}

async function update(id, data) {
  const service = await Service.findByPk(id);
  if (!service) throw Object.assign(new Error('Service not found'), { status: 404 });
  return service.update(data);
}

async function remove(id) {
  const service = await Service.findByPk(id);
  if (!service) throw Object.assign(new Error('Service not found'), { status: 404 });
  await service.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
