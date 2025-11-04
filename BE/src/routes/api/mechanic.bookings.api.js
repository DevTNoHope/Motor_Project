const router = require('express').Router();
const { param, body } = require('express-validator');
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/mechanic.booking.controller');

router.use(verifyJWT, requireRole('MECHANIC'));

router.patch('/:id/diagnose',
  param('id').isInt().toInt(),
  // body tối thiểu cho REPAIR (laborEstMin có thể 0 nếu chỉ QUICK? => tùy business)
  body('laborEstMin').optional().isInt({ min: 0 }).toInt(),
  body('etaMin').optional().isInt({ min: 0 }).toInt(),
  body('diagnosisNote').optional().isString(),
  body('requiredParts').optional().isArray(),
  ctrl.diagnose
);

router.patch('/:id/start',   param('id').isInt().toInt(), ctrl.start);
router.patch('/:id/complete',param('id').isInt().toInt(), ctrl.complete);

module.exports = router;
