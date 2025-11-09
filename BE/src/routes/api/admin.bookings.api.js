const router = require('express').Router();
const { query, param, body } = require('express-validator');
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/admin.booking.controller');

router.use(verifyJWT, requireRole('ADMIN'));

router.get('/',
  query('status').optional().isString(),
  query('dateFrom').optional().isISO8601(),
  query('dateTo').optional().isISO8601(),
  query('mechanicId').optional().isInt().toInt(),
  query('page').optional().isInt({ min:1 }).toInt(),
  query('size').optional().isInt({ min:1, max:100 }).toInt(),
  ctrl.list
);

router.patch('/:id/approve', param('id').isInt().toInt(), ctrl.approve);

router.patch('/:id/assign',
  param('id').isInt().toInt(),
  body('mechanicId').isInt().withMessage('mechanicId required').toInt(),
  ctrl.assign
);

router.patch('/:id/cancel',
  param('id').isInt().toInt(),
  body('reason').optional().isString(),
  ctrl.cancel
);

module.exports = router;
