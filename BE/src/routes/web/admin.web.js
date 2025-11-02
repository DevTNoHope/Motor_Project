const router = require('express').Router();
const axios = require('axios'); // dùng gọi nội bộ API login
const { requireAdmin } = require('../../middlewares/webAuth');

// Trang login
router.get('/admin/login', (req, res) => {
  res.render('admin/login', { title: 'Admin Login', error: null });
});

// Submit login -> gọi API /api/v1/auth/login -> set cookie
router.post('/admin/login', async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const { data } = await axios.post(`${baseURL}/auth/login`, { email, phone, password });
    if (data.role !== 'ADMIN') {
      return res.render('admin/login', { title: 'Admin Login', error: 'Tài khoản không có quyền ADMIN' });
    }
    // Lưu JWT vào cookie HttpOnly
    res.cookie('token', data.accessToken, {
      httpOnly: true,
      secure: false,        // đặt true nếu chạy HTTPS
      sameSite: 'lax',
      maxAge: 24 * 60 * 60 * 1000
    });
    return res.redirect('/admin');
  } catch (e) {
    return res.render('admin/login', { title: 'Admin Login', error: 'Đăng nhập thất bại' });
  }
});

// ---- Các trang admin bên dưới đều cần ADMIN ----
router.get('/admin', requireAdmin, (req, res) => {
  res.render('admin/dashboard', { title: 'Admin Dashboard' });
});

// ĐĂNG XUẤT: xóa cookie và về login
router.get('/admin/logout', (req, res) => {
  res.clearCookie('token');
  return res.redirect('/admin/login');
});

module.exports = router;
