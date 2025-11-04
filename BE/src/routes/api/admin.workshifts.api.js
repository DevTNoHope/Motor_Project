const router = require('express').Router();
const { query, body, param } = require('express-validator');
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/workshift.controller');

router.use(verifyJWT, requireRole('ADMIN'));

// GET /api/v1/admin/workshifts?mechanicId=&dateFrom=&dateTo=
router.get('/',
  query('mechanicId').optional().isInt().toInt(),
  query('dateFrom').optional().isISO8601(),
  query('dateTo').optional().isISO8601(),
  ctrl.list
);

// POST /api/v1/admin/workshifts
router.post('/',
  body('mechanic_id').isInt().toInt(),
  body('work_date').isISO8601(),          // YYYY-MM-DD
  body('start_min').isInt({ min:0, max:1440 }).toInt(),
  body('end_min').isInt({ min:1, max:1440 }).toInt(),
  body('step_min').optional().isInt({ min:1, max:120 }).toInt(),
  ctrl.create
);

// PATCH /api/v1/admin/workshifts/:id
router.patch('/:id',
  param('id').isInt().toInt(),
  body('mechanic_id').optional().isInt().toInt(),
  body('work_date').optional().isISO8601(),
  body('start_min').optional().isInt({ min:0, max:1440 }).toInt(),
  body('end_min').optional().isInt({ min:1, max:1440 }).toInt(),
  body('step_min').optional().isInt({ min:1, max:120 }).toInt(),
  ctrl.update
);

// DELETE /api/v1/admin/workshifts/:id
router.delete('/:id',
  param('id').isInt().toInt(),
  ctrl.remove
);

module.exports = router;
