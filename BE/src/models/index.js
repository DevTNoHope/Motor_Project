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

// Associations
Acc.belongsTo(Role, { foreignKey: 'role_id' });
Role.hasMany(Acc,   { foreignKey: 'role_id' });

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

module.exports = { sequelize, Role, Acc, User, Emp, Vehicle, Service, Booking, BookingService, Diagnosis, Workshift };
