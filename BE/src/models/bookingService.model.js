const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('BookingService', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    booking_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    service_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    qty: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
    price_snapshot: { type: DataTypes.DECIMAL(10,2), allowNull: true },
    duration_snapshot_min: { type: DataTypes.INTEGER, allowNull: true }
  }, { tableName: 'Booking_Service', timestamps: false });
