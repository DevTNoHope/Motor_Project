const router = require('express').Router();
const { verifyJWT } = require('../../middlewares/auth');
const { body, param } = require('express-validator');
const ctrl = require('../../controllers/booking.controller');

router.use(verifyJWT);

// POST /api/v1/bookings  (User tạo đơn)
router.post('/',
  body('vehicleId').isInt(),
  body('serviceIds').isArray({ min:1 }),
  body('serviceIds.*').isInt(),
  body('mechanicId').optional({ nullable:true }).isInt(),
  body('start').isISO8601(),        // ISO time (UTC hoặc local có offset)
  body('notesUser').optional().isString(),
  ctrl.create
);

// GET /api/v1/bookings/me
router.get('/me', ctrl.myList);

// GET /api/v1/bookings/:id
router.get('/:id', param('id').isInt(), ctrl.detail);

// PATCH /api/v1/bookings/:id/cancel
router.patch('/:id/cancel', param('id').isInt(), ctrl.cancel);

module.exports = router;
