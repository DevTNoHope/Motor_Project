const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('ServicePart', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    service_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    part_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    qty_per_service: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 }
  }, {
    tableName: 'Service_Parts',
    timestamps: false,
    indexes: [
      { unique: true, fields: ['service_id', 'part_id'] }
    ]
  });
