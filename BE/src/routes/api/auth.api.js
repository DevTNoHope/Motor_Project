const router = require('express').Router();
const { body, oneOf } = require('express-validator');
const { register, loginCtrl } = require('../../controllers/auth.controller');

/**
 * Đăng ký khách hàng (USER)
 * - yêu cầu: password, name
 * - email hoặc phone (ít nhất một)
 */
router.post(
  '/register',
  oneOf([
    body('email').isEmail().withMessage('Invalid email'),
    body('phone').isString().isLength({ min: 8 }).withMessage('Invalid phone')
  ], 'Email or phone required'),
  body('password').isLength({ min: 6 }),
  body('name').isLength({ min: 2 }),
  register
);

/**
 * Đăng nhập bằng email hoặc phone
 */
router.post(
  '/login',
  oneOf([
    body('email').isEmail(),
    body('phone').isString().isLength({ min: 8 })
  ], 'Email or phone required'),
  body('password').isLength({ min: 6 }),
  loginCtrl
);

module.exports = router;
