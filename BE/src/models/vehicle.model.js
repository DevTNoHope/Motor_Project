const { DataTypes } = require('sequelize');
module.exports = (sequelize) =>
  sequelize.define('Vehicle', {
    id:       { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    user_id:  { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    plate_no: { type: DataTypes.STRING(32), allowNull: false },
    brand:    { type: DataTypes.STRING(100) },
    model:    { type: DataTypes.STRING(100) },
    year:     { type: DataTypes.INTEGER },
    color:    { type: DataTypes.STRING(50) }
  }, {
    tableName: 'Vehicles',
    timestamps: false,
    indexes: [{ unique: true, fields: ['user_id', 'plate_no'] }]
  });
