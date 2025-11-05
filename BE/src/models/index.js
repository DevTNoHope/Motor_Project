const { sequelize } = require('../config/db');

const Role = require('./role.model')(sequelize);
const Acc  = require('./acc.model')(sequelize);
const User = require('./user.model')(sequelize);
const Emp  = require('./employee.model')(sequelize);
const Vehicle = require('./vehicle.model')(sequelize);
const Service = require('./service.model')(sequelize);
const Booking = require('./booking.model')(sequelize);
const BookingService = require('./bookingService.model')(sequelize);
const Diagnosis = require('./diagnosis.model')(sequelize);
const Workshift = require('./workshift.model')(sequelize);
const ServicePart = require('./servicePart.model')(sequelize);
const BookingPart = require('./bookingPart.model')(sequelize);
const PartType = require('./partType.model')(sequelize);
const Part = require('./part.model')(sequelize);
const PurchaseOrder = require('./purchaseOrder.model')(sequelize);
const PurchaseOrderItem = require('./purchaseOrderItem.model')(sequelize);
const Inventory = require('./inventory.model')(sequelize);
const Supplier = require('./supplier.model')(sequelize);

// Associations
Acc.belongsTo(Role, { foreignKey: 'role_id' });
Role.hasMany(Acc,   { foreignKey: 'role_id' });

Acc.hasOne(Emp, { foreignKey: 'acc_id' });

User.belongsTo(Acc, { foreignKey: 'acc_id', onDelete: 'CASCADE' });
Emp.belongsTo(Acc,  { foreignKey: 'acc_id', onDelete: 'CASCADE' });

Vehicle.belongsTo(User, { foreignKey: 'user_id', onDelete: 'CASCADE' });
User.hasMany(Vehicle,   { foreignKey: 'user_id' });

Booking.belongsTo(User,    { foreignKey: 'user_id' });
Booking.belongsTo(Emp,     { foreignKey: 'mechanic_id' });
Booking.belongsTo(Vehicle, { foreignKey: 'vehicle_id' });

BookingService.belongsTo(Booking, { foreignKey: 'booking_id', onDelete: 'CASCADE' });
Booking.hasMany(BookingService,   { foreignKey: 'booking_id' });

BookingService.belongsTo(Service, { foreignKey: 'service_id' });
Service.hasMany(BookingService,   { foreignKey: 'service_id' });

Diagnosis.belongsTo(Booking, { foreignKey: 'booking_id', onDelete: 'CASCADE' });
Booking.hasOne(Diagnosis,    { foreignKey: 'booking_id' });

Workshift.belongsTo(Emp, { foreignKey: 'mechanic_id', onDelete: 'CASCADE' });
Emp.hasMany(Workshift,   { foreignKey: 'mechanic_id' });

Part.belongsTo(PartType, { foreignKey: 'type_id' });
PartType.hasMany(Part, { foreignKey: 'type_id' });

PurchaseOrder.hasMany(PurchaseOrderItem, { foreignKey: 'po_id' });
PurchaseOrderItem.belongsTo(PurchaseOrder, { foreignKey: 'po_id' });

// --- ✅ Thêm liên kết Part <-> PurchaseOrderItem ---
Part.hasMany(PurchaseOrderItem, { foreignKey: 'part_id' });
PurchaseOrderItem.belongsTo(Part, { foreignKey: 'part_id' })

Part.hasOne(Inventory, { foreignKey: 'part_id' });
Inventory.belongsTo(Part, { foreignKey: 'part_id' });

BookingPart.belongsTo(Booking, { foreignKey: 'booking_id', onDelete: 'CASCADE' });
Booking.hasMany(BookingPart,   { foreignKey: 'booking_id' });

ServicePart.belongsTo(Service, { foreignKey: 'service_id' });
Service.hasMany(ServicePart,   { foreignKey: 'service_id' });

BookingPart.belongsTo(Part,    { foreignKey: 'part_id' });
Part.hasMany(BookingPart,      { foreignKey: 'part_id' });

module.exports = { sequelize, Role, Acc, User, Emp, Vehicle, Service, Booking, BookingService, Diagnosis, Workshift, PartType, Part, PurchaseOrder, PurchaseOrderItem, Inventory, ServicePart, BookingPart, Supplier };

