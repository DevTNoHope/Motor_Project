const router = require('express').Router();
const { body } = require('express-validator');
const { verifyJWT } = require('../../middlewares/auth');
const { getMe, patchMe } = require('../../controllers/me.controller');

router.use(verifyJWT);

/**
 * GET /api/v1/me
 * Trả thông tin account + profile theo role (USER hoặc MECHANIC)
 */
router.get('/', getMe);

/**
 * PATCH /api/v1/me
 * - USER được sửa: account(name, gender, birth_year, avatar_url) + profile(address, note)
 * - MECHANIC được sửa: account(name, gender, birth_year, avatar_url) + profile(skill_tags, hired_at)
 */
router.patch('/',
  // validators nhẹ cho dữ liệu thường gặp; cái nào không gửi thì bỏ qua
  body('name').optional().isString().isLength({ min: 2 }),
  body('gender').optional().isIn(['M','F','O']),
  body('birth_year').optional().isInt({ min: 1900, max: 2100 }),
  body('avatar_url').optional().isString(),

  // USER
  body('address').optional().isString(),
  body('note').optional().isString(),

  // MECHANIC
  body('skill_tags').optional().isString(),
  body('hired_at').optional().isISO8601(),

  patchMe
);

// (tuỳ chọn) alias dành riêng cho thợ:
router.get('/mechanic', getMe);
router.patch('/mechanic',
  body('name').optional().isString().isLength({ min: 2 }),
  body('gender').optional().isIn(['M','F','O']),
  body('birth_year').optional().isInt({ min: 1900, max: 2100 }),
  body('avatar_url').optional().isString(),
  body('skill_tags').optional().isString(),
  body('hired_at').optional().isISO8601(),
  patchMe
);

module.exports = router;
