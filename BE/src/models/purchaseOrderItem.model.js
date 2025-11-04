const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('PurchaseOrderItem', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    po_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    part_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    qty: { type: DataTypes.INTEGER, allowNull: false },
    cost_price: { type: DataTypes.DECIMAL(10, 2), allowNull: false }
  }, { tableName: 'PurchaseOrderItems', timestamps: false });
