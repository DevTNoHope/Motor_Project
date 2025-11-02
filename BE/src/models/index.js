const { sequelize } = require('../config/db');

const Role = require('./role.model')(sequelize);
const Acc  = require('./acc.model')(sequelize);
const User = require('./user.model')(sequelize);
const Emp  = require('./employee.model')(sequelize);

// Associations
Acc.belongsTo(Role, { foreignKey: 'role_id' });
Role.hasMany(Acc,   { foreignKey: 'role_id' });

User.belongsTo(Acc, { foreignKey: 'acc_id', onDelete: 'CASCADE' });
Emp.belongsTo(Acc,  { foreignKey: 'acc_id', onDelete: 'CASCADE' });

module.exports = { sequelize, Role, Acc, User, Emp };
