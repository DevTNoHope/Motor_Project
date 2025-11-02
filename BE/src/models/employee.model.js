const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Employee', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    acc_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false, unique: true },
    skill_tags: { type: DataTypes.TEXT, allowNull: true },
    hired_at: { type: DataTypes.DATEONLY, allowNull: true }
  }, { tableName: 'Employees', timestamps: false });
