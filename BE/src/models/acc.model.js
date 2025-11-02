const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Acc', {
    id: { type: DataTypes.BIGINT.UNSIGNED, autoIncrement: true, primaryKey: true },
    role_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    email: { type: DataTypes.STRING(191), allowNull: true, unique: true },
    phone: { type: DataTypes.STRING(24), allowNull: true, unique: true },
    password_hash: { type: DataTypes.STRING(191), allowNull: false },
    name: { type: DataTypes.STRING(191), allowNull: false },
    gender: { type: DataTypes.ENUM('M','F','O'), allowNull: true },
    birth_year: { type: DataTypes.INTEGER, allowNull: true },
    avatar_url: { type: DataTypes.TEXT, allowNull: true },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
  }, { tableName: 'Accs', timestamps: false });
