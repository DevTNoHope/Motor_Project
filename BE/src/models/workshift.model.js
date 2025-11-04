const { DataTypes } = require('sequelize');

module.exports = (sequelize) =>
  sequelize.define('Workshift', {
    id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
    mechanic_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
    work_date: { type: DataTypes.DATEONLY, allowNull: false }, // YYYY-MM-DD
    start_min: { type: DataTypes.INTEGER, allowNull: false },  // phút từ 00:00 (540 = 09:00)
    end_min: { type: DataTypes.INTEGER, allowNull: false },    // phút từ 00:00 (1020 = 17:00)
    step_min: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 15 }
  }, {
    tableName: 'LichLamViec',
    timestamps: false,
    indexes: [
      { fields: ['mechanic_id', 'work_date'] }
    ]
  });
