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
// TODO: sau này thêm:
// router.use('/auth', require('./auth.api'));
// router.use('/services', require('./services.api'));
// router.use('/bookings', require('./bookings.api'));
// ...

module.exports = router;
