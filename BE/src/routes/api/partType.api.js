const router = require('express').Router();
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/partType.controller');

router.use(verifyJWT, requireRole('ADMIN'));
router.get('/', ctrl.getAll);
router.post('/', ctrl.create);
router.patch('/:id', ctrl.update);
router.delete('/:id', ctrl.remove);

module.exports = router;
