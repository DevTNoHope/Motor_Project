const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('User', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    acc_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false, unique: true },
    address: { type: DataTypes.TEXT, allowNull: true },
    note: { type: DataTypes.TEXT, allowNull: true }
  }, { tableName: 'Users', timestamps: false });
