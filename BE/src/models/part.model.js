const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Part', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    type_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    name: { type: DataTypes.STRING(191), allowNull: false },
    sku: { type: DataTypes.STRING(64), allowNull: false, unique: true },
    unit: { type: DataTypes.STRING(20), allowNull: false },   // cái, bộ, lít, ...
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    is_active: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true }
  }, {
    tableName: 'Parts',
    timestamps: false
  });
