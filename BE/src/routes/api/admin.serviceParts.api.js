const router = require('express').Router();
const { query, body, param } = require('express-validator');
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/servicePart.controller');

router.use(verifyJWT, requireRole('ADMIN'));

/**
 * GET /api/v1/admin/service-parts?serviceId=&partId=
 */
router.get('/',
  query('serviceId').optional().isInt().toInt(),
  query('partId').optional().isInt().toInt(),
  ctrl.list
);

/**
 * POST /api/v1/admin/service-parts
 * body: { service_id, part_id, qty_per_service }
 */
router.post('/',
  body('service_id').isInt({ min:1 }).toInt(),
  body('part_id').isInt({ min:1 }).toInt(),
  body('qty_per_service').isInt({ min:1 }).toInt(),
  ctrl.create
);

/**
 * PATCH /api/v1/admin/service-parts/:id
 * body: { service_id?, part_id?, qty_per_service? }
 */
router.patch('/:id',
  param('id').isInt().toInt(),
  body('service_id').optional().isInt({ min:1 }).toInt(),
  body('part_id').optional().isInt({ min:1 }).toInt(),
  body('qty_per_service').optional().isInt({ min:1 }).toInt(),
  ctrl.update
);

/**
 * DELETE /api/v1/admin/service-parts/:id
 */
router.delete('/:id',
  param('id').isInt().toInt(),
  ctrl.remove
);

module.exports = router;
