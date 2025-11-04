const { sequelize } = require('../config/db');

const Role = require('./role.model')(sequelize);
const Acc  = require('./acc.model')(sequelize);
const User = require('./user.model')(sequelize);
const Emp  = require('./employee.model')(sequelize);

const PartType = require('./partType.model')(sequelize);
const Part = require('./part.model')(sequelize);
const Service = require('./service.model')(sequelize);

const PurchaseOrder = require('./purchaseOrder.model')(sequelize);
const PurchaseOrderItem = require('./purchaseOrderItem.model')(sequelize);
const Inventory = require('./inventory.model')(sequelize);
// Associations
Acc.belongsTo(Role, { foreignKey: 'role_id' });
Role.hasMany(Acc,   { foreignKey: 'role_id' });

User.belongsTo(Acc, { foreignKey: 'acc_id', onDelete: 'CASCADE' });
Emp.belongsTo(Acc,  { foreignKey: 'acc_id', onDelete: 'CASCADE' });

Part.belongsTo(PartType, { foreignKey: 'type_id' });
PartType.hasMany(Part, { foreignKey: 'type_id' });
Emp.belongsTo(Acc, { foreignKey: 'acc_id' });
Acc.hasOne(Emp, { foreignKey: 'acc_id' });

PurchaseOrder.hasMany(PurchaseOrderItem, { foreignKey: 'po_id' });
PurchaseOrderItem.belongsTo(PurchaseOrder, { foreignKey: 'po_id' });

// --- ✅ Thêm liên kết Part <-> PurchaseOrderItem ---
Part.hasMany(PurchaseOrderItem, { foreignKey: 'part_id' });
PurchaseOrderItem.belongsTo(Part, { foreignKey: 'part_id' })

Part.hasOne(Inventory, { foreignKey: 'part_id' });
Inventory.belongsTo(Part, { foreignKey: 'part_id' });
module.exports = { sequelize, Role, Acc, User, Emp , PartType, Part, Service, PurchaseOrder, PurchaseOrderItem, Inventory };
