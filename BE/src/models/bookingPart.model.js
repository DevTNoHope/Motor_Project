const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('BookingPart', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    booking_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    part_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    qty: { type: DataTypes.INTEGER, allowNull: false },
    price_snapshot: { type: DataTypes.DECIMAL(10,2), allowNull: true },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
  }, { tableName: 'Booking_Parts', timestamps: false });
