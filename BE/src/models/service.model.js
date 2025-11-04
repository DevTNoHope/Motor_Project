const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Service', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING(191), allowNull: false },
    type: { type: DataTypes.STRING(50), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    default_duration_min: { type: DataTypes.INTEGER, allowNull: true },
    base_price: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 0 },
    is_active: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true }
  }, { tableName: 'services', timestamps: false });
