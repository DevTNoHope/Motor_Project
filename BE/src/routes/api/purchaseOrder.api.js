const router = require('express').Router();
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/purchaseOrder.controller');

router.use(verifyJWT, requireRole('ADMIN'));

router.get('/', ctrl.getAll);
router.get('/:id', ctrl.getById);
router.post('/', ctrl.create);
router.patch('/:id', ctrl.update);
router.post('/:id/receive', ctrl.receive);
router.delete('/:id', ctrl.remove);

module.exports = router;
