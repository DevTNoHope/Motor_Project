const router = require('express').Router();
const { param, body } = require('express-validator');
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/admin.booking.controller');

router.use(verifyJWT, requireRole('ADMIN'));

router.patch('/:id/approve', param('id').isInt().toInt(), ctrl.approve);

router.patch('/:id/assign',
  param('id').isInt().toInt(),
  body('mechanicId').isInt().withMessage('mechanicId required').toInt(),
  ctrl.assign
);

module.exports = router;
