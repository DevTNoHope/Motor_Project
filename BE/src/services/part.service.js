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
  // Chỉ thêm các trường name, type_id, sku, unit, price, is_active
  return Part.create({
    type_id: data.type_id,
    name: data.name,
    sku: data.sku,
    unit: data.unit,
    price: data.price,
    is_active: data.is_active ?? true
  });
}

async function update(id, data) {
  const part = await Part.findByPk(id);
  if (!part) throw Object.assign(new Error('Part not found'), { status: 404 });
  return part.update({
    type_id: data.type_id ?? part.type_id,
    name: data.name ?? part.name,
    sku: data.sku ?? part.sku,
    unit: data.unit ?? part.unit,
    price: data.price ?? part.price,
    is_active: data.is_active ?? part.is_active
  });
}

async function remove(id) {
  const part = await Part.findByPk(id);
  if (!part) throw Object.assign(new Error('Part not found'), { status: 404 });
  await part.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, remove };
