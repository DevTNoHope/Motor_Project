const { PurchaseOrder, PurchaseOrderItem, Inventory, Part } = require('../models');
const { sequelize } = require('../config/db');

// ✅ Lấy tất cả phiếu nhập
async function getAll() {
  return PurchaseOrder.findAll({
    include: [{ model: PurchaseOrderItem, include: [Part] }],
    order: [['id', 'DESC']]
  });
}

// ✅ Lấy chi tiết phiếu nhập
async function getById(id) {
  const po = await PurchaseOrder.findByPk(id, {
    include: [{ model: PurchaseOrderItem, include: [Part] }]
  });
  if (!po) throw Object.assign(new Error('Không tìm thấy đơn đặt hàng'), { status: 404 });
  return po;
}

// ✅ Tạo phiếu nhập (DRAFT)
async function create(data) {
  const t = await sequelize.transaction();
  try {
    const po = await PurchaseOrder.create({
      supplier_id: data.supplier_id,
      created_by: data.created_by,
      note: data.note || null
    }, { transaction: t });

    if (Array.isArray(data.items) && data.items.length > 0) {
      for (const item of data.items) {
        await PurchaseOrderItem.create({
          po_id: po.id,
          part_id: item.part_id,
          qty: item.qty,
          cost_price: item.cost_price
        }, { transaction: t });
      }
    }

    await t.commit();
    return po;
  } catch (e) {
    await t.rollback();
    throw e;
  }
}

// ✅ Cập nhật phiếu (sửa note hoặc items nếu vẫn ở DRAFT)
async function update(id, data) {
  const po = await PurchaseOrder.findByPk(id);
  if (!po) throw Object.assign(new Error('Không tìm thấy đơn đặt hàng'), { status: 404 });
  if (po.status !== 'DRAFT')
    throw Object.assign(new Error('Chỉ có thể cập nhật các lệnh DRAFT'), { status: 400 });

  await po.update({ note: data.note ?? po.note });

  if (Array.isArray(data.items)) {
    await PurchaseOrderItem.destroy({ where: { po_id: id } });
    for (const item of data.items) {
      await PurchaseOrderItem.create({
        po_id: id,
        part_id: item.part_id,
        qty: item.qty,
        cost_price: item.cost_price
      });
    }
  }

  return po;
}

// ✅ Xác nhận phiếu (RECEIVED) → cập nhật Inventory
async function receive(id) {
  const t = await sequelize.transaction();
  try {
    const po = await PurchaseOrder.findByPk(id, {
      include: [PurchaseOrderItem]
    });
    if (!po) throw Object.assign(new Error('Không tìm thấy đơn đặt hàng'), { status: 404 });
    if (po.status !== 'DRAFT')
      throw Object.assign(new Error('Chỉ có thể nhận được đơn hàng DRAFT'), { status: 400 });

    for (const item of po.PurchaseOrderItems) {
      const inv = await Inventory.findOne({ where: { part_id: item.part_id }, transaction: t });
      if (inv) {
        await inv.update({ qty: inv.qty + item.qty }, { transaction: t });
      } else {
        await Inventory.create({ part_id: item.part_id, qty: item.qty }, { transaction: t });
      }
    }

    await po.update({ status: 'RECEIVED' }, { transaction: t });
    await t.commit();
    return { message: 'Đã nhận được đơn đặt hàng và cập nhật hàng tồn kho' };
  } catch (e) {
    await t.rollback();
    throw e;
  }
}

// ✅ Xóa phiếu nhập
async function remove(id) {
  const po = await PurchaseOrder.findByPk(id);
  if (!po) throw Object.assign(new Error('Purchase order not found'), { status: 404 });
  if (po.status !== 'DRAFT')
    throw Object.assign(new Error('Only DRAFT orders can be deleted'), { status: 400 });
  await po.destroy();
  return { message: 'Deleted successfully' };
}

module.exports = { getAll, getById, create, update, receive, remove };
