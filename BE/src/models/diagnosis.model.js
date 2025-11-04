const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Diagnosis', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    booking_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false, unique: true },
    diagnosis_note: { type: DataTypes.TEXT, allowNull: false, defaultValue: '' },
    eta_min: { type: DataTypes.INTEGER, allowNull: true },
    labor_est_min: { type: DataTypes.INTEGER, allowNull: true },
    required_parts: { type: DataTypes.JSON, allowNull: true },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
  }, {
    tableName: 'PhieuDanhGiaXe',
    timestamps: false
  });
