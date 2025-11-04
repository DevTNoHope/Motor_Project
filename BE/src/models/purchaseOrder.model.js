const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('PurchaseOrder', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    supplier_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    created_by: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false }, // Accs.id
    status: {
      type: DataTypes.ENUM('DRAFT', 'RECEIVED', 'CANCELED'),
      allowNull: false,
      defaultValue: 'DRAFT'
    },
    note: { type: DataTypes.TEXT, allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
  }, { tableName: 'PurchaseOrders', timestamps: false });
