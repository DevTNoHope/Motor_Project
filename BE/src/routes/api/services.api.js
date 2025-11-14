const router = require('express').Router();
const { verifyJWT, requireRole } = require('../../middlewares/auth');
const ctrl = require('../../controllers/service.controller');


router.use(verifyJWT);

router.get('/', ctrl.getAll);
router.get('/:id', ctrl.getById);
router.post('/', ctrl.create);
router.patch('/:id', ctrl.update);
router.delete('/:id', ctrl.remove);

module.exports = router;
