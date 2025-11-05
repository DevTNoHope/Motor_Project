const { Supplier } = require('../models');

async function getAll() {
  return Supplier.findAll({ order: [['id', 'ASC']] });
}

async function getById(id) {
  const supplier = await Supplier.findByPk(id);
  if (!supplier) throw Object.assign(new Error('Supplier not found'), { status: 404 });
  return supplier;
}

async function create(data) {
  return Supplier.create({
    name: data.name,
    contact_phone: data.contact_phone,
    address: data.address
  });
}

async function update(id, data) {
  const supplier = await Supplier.findByPk(id);
  if (!supplier) throw Object.assign(new Error('Supplier not found'), { status: 404 });
  return supplier.update({
    name: data.name ?? supplier.name,
    contact_phone: data.contact_phone ?? supplier.contact_phone,
    address: data.address ?? supplier.address
  });
}

async function remove(id) {
  const supplier = await Supplier.findByPk(id);
  if (!supplier) throw Object.assign(new Error('Supplier not found'), { status: 404 });
  await supplier.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
