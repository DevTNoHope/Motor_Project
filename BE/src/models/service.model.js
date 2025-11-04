const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Service', {
    id:   { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(191), allowNull: false },
    type: { type: DataTypes.ENUM('QUICK','REPAIR'), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    default_duration_min: { type: DataTypes.INTEGER, allowNull: true },
    base_price: { type: DataTypes.DECIMAL(10,2), allowNull: true },
    is_active: { type: DataTypes.BOOLEAN, defaultValue: true }
  }, { tableName: 'Services', timestamps: false });
