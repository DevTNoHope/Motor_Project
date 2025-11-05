const { Op } = require('sequelize');
const { ServicePart, Service, Part } = require('../models');

async function assertRefs({ service_id, part_id }) {
  const s = await Service.findByPk(service_id);
  if (!s) { const e = new Error('Service not found'); e.status = 404; throw e; }
  if (s.type !== 'QUICK') { const e = new Error('Only QUICK services can have default parts'); e.status = 400; throw e; }

  const p = await Part.findByPk(part_id);
  if (!p) { const e = new Error('Part not found'); e.status = 404; throw e; }
}

async function list({ serviceId, partId }) {
  const where = {};
  if (serviceId) where.service_id = serviceId;
  if (partId) where.part_id = partId;

  return ServicePart.findAll({
    where,
    order: [['service_id','ASC'], ['part_id','ASC']]
  });
}

async function create({ service_id, part_id, qty_per_service }) {
  await assertRefs({ service_id, part_id });

  // tránh trùng (dù DB có unique)
  const exist = await ServicePart.findOne({ where: { service_id, part_id } });
  if (exist) { const e = new Error('Mapping already exists'); e.status = 409; e.code='DUPLICATE'; throw e; }

  return ServicePart.create({ service_id, part_id, qty_per_service });
}

async function update(id, patch) {
  const row = await ServicePart.findByPk(id);
  if (!row) { const e = new Error('ServicePart not found'); e.status = 404; throw e; }

  const next = {
    service_id: patch.service_id ?? row.service_id,
    part_id: patch.part_id ?? row.part_id,
    qty_per_service: patch.qty_per_service ?? row.qty_per_service
  };

  if (patch.service_id || patch.part_id) {
    await assertRefs({ service_id: next.service_id, part_id: next.part_id });
    // check duplicate (exclude self)
    const dup = await ServicePart.findOne({
      where: {
        id: { [Op.ne]: row.id },
        service_id: next.service_id,
        part_id: next.part_id
      }
    });
    if (dup) { const e = new Error('Mapping already exists'); e.status = 409; e.code='DUPLICATE'; throw e; }
  }

  await row.update(next);
  return row;
}

async function remove(id) {
  const rows = await ServicePart.destroy({ where: { id } });
  if (!rows) { const e = new Error('ServicePart not found'); e.status = 404; throw e; }
  return { ok: true };
}

module.exports = { list, create, update, remove };
