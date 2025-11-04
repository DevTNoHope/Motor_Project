const router = require('express').Router();
const { verifyJWT } = require('../../middlewares/auth');
const { body, param } = require('express-validator');
const ctrl = require('../../controllers/vehicle.controller');

router.use(verifyJWT);

// GET /api/v1/me/vehicles
router.get('/', ctrl.list);

// GET /api/v1/me/vehicles/:id
router.get('/:id', param('id').isInt(), ctrl.detail);

// POST /api/v1/me/vehicles
router.post('/',
  body('plate_no').isString().trim().isLength({ min: 4 }).withMessage('plate_no required'),
  body('brand').optional().isString(),
  body('model').optional().isString(),
  body('year').optional().isInt({ min: 1900, max: 2100 }),
  body('color').optional().isString(),
  ctrl.create
);

// PATCH /api/v1/me/vehicles/:id
router.patch('/:id',
  param('id').isInt(),
  body('plate_no').optional().isString().trim().isLength({ min: 4 }),
  body('brand').optional().isString(),
  body('model').optional().isString(),
  body('year').optional().isInt({ min: 1900, max: 2100 }),
  body('color').optional().isString(),
  ctrl.update
);

// DELETE /api/v1/me/vehicles/:id
router.delete('/:id', param('id').isInt(), ctrl.remove);

module.exports = router;
