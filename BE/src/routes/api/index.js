const router = require('express').Router();

router.use('/health', require('./health.api'));
router.use('/auth', require('./auth.api'));
router.use('/me', require('./me.api'));
router.use('/me/vehicles', require('./me.vehicles.api'));
router.use('/bookings', require('./bookings.api'));
router.use('/admin/bookings', require('./admin.bookings.api')); 
router.use('/mechanic/bookings', require('./mechanic.bookings.api'));
router.use('/slots', require('./slots.api'));
router.use('/diagnosis', require('./diagnosis.api'));
router.use('/admin/workshifts', require('./admin.workshifts.api'));

router.use('/part-types', require('./partType.api'));
router.use('/parts', require('./parts.api'));
router.use('/employees', require('./employee.api'));
router.use('/services', require('./services.api'));
router.use('/purchase-orders', require('./purchaseOrder.api'));
router.use('/admin/service-parts', require('./admin.serviceParts.api'));

router.use('/suppliers', require('./supplier.api'));
router.use("/admin", require("./admin.stats.api"));
router.use("/admin/stats", require("./admin.stats.api"));

router.use('/mechanic/parts', require('./mechanic.parts.api'));

router.use('/notifications', require('./notifications.api'));

router.use('/mechanic/stats', require('./mechanic.stats.api'));

module.exports = router;
