const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Part', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    type_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    name: { type: DataTypes.STRING(191), allowNull: false },
    sku: { type: DataTypes.STRING(64), allowNull: true }, // ✅ thêm dòng này
    supplier_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: true },
    price: { type: DataTypes.DECIMAL(10,2), allowNull: false, defaultValue: 0 },
    unit: { type: DataTypes.STRING(50), allowNull: true },
    quantity_in_stock: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
    is_active: { type: DataTypes.BOOLEAN, defaultValue: true }
  }, { tableName: 'Parts', timestamps: false });
