const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('PartType', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING(191), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true }
  }, { tableName: 'PartTypes', timestamps: false });
