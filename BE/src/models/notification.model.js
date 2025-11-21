// models/notification.model.js
const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Notification', {
    id: {
      type: DataTypes.BIGINT.UNSIGNED,
      primaryKey: true,
      autoIncrement: true,
    },

    user_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: false,
    },

    title: {
      type: DataTypes.STRING(191),
      allowNull: false,
    },

    body: {
      type: DataTypes.TEXT,
      allowNull: false,
    },

    type: {
      // Bạn có thể thêm/bớt type theo nhu cầu
      type: DataTypes.ENUM(
        'BOOKING_CREATED',
        'BOOKING_CANCELLED',
        'BOOKING_APPROVED',
        'BOOKING_REJECTED',
        'BOOKING_STARTED',
        'BOOKING_IN_DIAGNOSIS',
        'BOOKING_IN_PROGRESS',
        'BOOKING_DONE',
        'REVIEW_CREATED'
      ),
      allowNull: false,
    },

    booking_id: {
      type: DataTypes.BIGINT.UNSIGNED,
      allowNull: true,
    },

    is_read: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },

    // Nếu bạn đang dùng pattern created_at như các model khác:
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  }, {
    tableName: 'Notifications',
    timestamps: false,
  });
