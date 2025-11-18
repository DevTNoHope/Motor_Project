const router = require('express').Router();
const { Part } = require('../../models');
const { verifyJWT, requireRole } = require('../../middlewares/auth');

// Chỉ cho thợ có token hợp lệ
router.use(verifyJWT, requireRole('MECHANIC'));

/**
 * GET /api/v1/mechanic/parts
 * ✅ Lấy danh sách phụ tùng đang hoạt động (active)
 */
router.get('/', async (req, res, next) => {
  try {
    const parts = await Part.findAll({
      where: { is_active: true },
      attributes: ['id', 'name', 'price', 'unit'],
      order: [['name', 'ASC']],
    });

    res.json(parts);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
