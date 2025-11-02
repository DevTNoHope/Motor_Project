const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Role', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    code: { type: DataTypes.STRING(32), allowNull: false, unique: true },
    name: { type: DataTypes.STRING(100), allowNull: false }
  }, { tableName: 'Roles', timestamps: false });
