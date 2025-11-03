const router = require('express').Router();

router.use('/health', require('./health.api'));
router.use('/auth', require('./auth.api'));
router.use('/me', require('./me.api'));

router.use('/part-types', require('./partType.api'));
router.use('/parts', require('./parts.api'));
router.use('/employees', require('./employee.api'));
// TODO: sau này thêm:
// router.use('/auth', require('./auth.api'));
// router.use('/services', require('./services.api'));
// router.use('/bookings', require('./bookings.api'));
// ...

module.exports = router;
