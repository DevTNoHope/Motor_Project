const router = require('express').Router();
const { query } = require('express-validator');
const { verifyJWT } = require('../../middlewares/auth');
const ctrl = require('../../controllers/slots.controller');

// Cho phép cả user & mechanic xem slot -> chỉ cần verifyJWT (nếu bạn muốn public thì bỏ verify)
router.use(verifyJWT);

router.get('/',
  query('date').isISO8601().withMessage('date=YYYY-MM-DD'),
  // mechanicId optional
  ctrl.getSlots
);

module.exports = router;
