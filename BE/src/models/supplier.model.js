const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Supplier', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING(191), allowNull: false },
    contact_phone: { type: DataTypes.STRING(32), allowNull: true },
    address: { type: DataTypes.TEXT, allowNull: true }
  }, { tableName: 'Suppliers', timestamps: false });
