const router = require('express').Router();
const { verifyJWT } = require('../../middlewares/auth');
const { param } = require('express-validator');
const ctrl = require('../../controllers/diagnosis.controller');

// Cho phép mechanic hoặc admin; hoặc user nếu booking là của họ (tuỳ bạn thêm check)
router.use(verifyJWT);

router.get('/by-booking/:bookingId', param('bookingId').isInt().toInt(), ctrl.getByBooking);

module.exports = router;
