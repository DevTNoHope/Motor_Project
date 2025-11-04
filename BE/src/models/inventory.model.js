const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Inventory', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    part_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    qty: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
    min_qty: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 }
  }, { tableName: 'Inventory', timestamps: false });
