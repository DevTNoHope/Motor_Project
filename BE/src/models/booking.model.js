const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Booking', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    user_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    mechanic_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: true },
    vehicle_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: true },
    start_dt: { type: DataTypes.DATE, allowNull: false },
    end_dt: { type: DataTypes.DATE, allowNull: true }, // REPAIR sẽ cập nhật sau chẩn đoán
    status: {
      type: DataTypes.ENUM('PENDING','APPROVED','IN_DIAGNOSIS','IN_PROGRESS','DONE','CANCELED'),
      allowNull: false, defaultValue: 'PENDING'
    },
    notes_user: { type: DataTypes.TEXT, allowNull: true },
    notes_mechanic: { type: DataTypes.TEXT, allowNull: true },
    created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
  }, { tableName: 'Bookings', timestamps: false });
