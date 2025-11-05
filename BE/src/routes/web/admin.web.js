const router = require('express').Router();
const axios = require('axios');
const { requireAdmin } = require('../../middlewares/webAuth');

// ==================== LOGIN / LOGOUT ==================== //
router.get('/admin/login', (req, res) => {
  res.render('admin/login', { title: 'Admin Login', error: null,layout: false });
});

router.post('/admin/login', async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const { data } = await axios.post(`${baseURL}/auth/login`, { email, phone, password });

    if (data.role !== 'ADMIN') {
      return res.render('admin/login', { title: 'Admin Login', error: 'Tài khoản không có quyền ADMIN' });
    }

    res.cookie('token', data.accessToken, {
      httpOnly: true,
      secure: false,
      sameSite: 'lax',
      maxAge: 24 * 60 * 60 * 1000
    });

    return res.redirect('/admin');
  } catch (e) {
    return res.render('admin/login', { title: 'Admin Login', error: 'Đăng nhập thất bại' });
  }
});

router.get('/admin/logout', (req, res) => {
  res.clearCookie('token');
  return res.redirect('/admin/login');
});

// ==================== DASHBOARD ==================== //
const { Emp, Part, PartType, Service, PurchaseOrder, Supplier } = require('../../models');

router.get('/admin', requireAdmin, async (req, res, next) => {
  try {
    const [
      mechanicCount,
      serviceCount,
      partCount,
      partTypeCount,
      supplierCount,
      purchaseOrderCount
    ] = await Promise.all([
      Emp.count(),
      Service.count(),
      Part.count(),
      PartType.count(),
      Supplier.count(),
      PurchaseOrder.count()
    ]);

    const stats = {
      mechanics: mechanicCount,
      services: serviceCount,
      parts: partCount,
      partTypes: partTypeCount,
      suppliers: supplierCount,
      purchaseOrders: purchaseOrderCount
    };

    res.render('admin/dashboard', {
      layout: 'layouts/admin',
      title: 'Bảng điều khiển',
      stats
    });
  } catch (err) {
    next(err);
  }
});

// ==================== QUẢN LÝ THỢ ==================== //
const { Acc } = require('../../models');

router.get('/admin/employees', requireAdmin, async (req, res, next) => {
  try {
    const employees = await Emp.findAll({
      include: [Acc],
      order: [['id', 'ASC']]
    });
    res.render('admin/employees', {
      layout: 'layouts/admin',
      title: 'Quản lý Thợ sửa xe',
      employees
    });
  } catch (err) {
    next(err);
  }
});

router.get('/admin/employees/new', requireAdmin, (req, res) => {
  res.render('admin/employee_form', {
    layout: 'layouts/admin',
    title: 'Thêm thợ mới',
    formTitle: 'Thêm thợ mới',
    formAction: '/admin/employees',
    method: 'POST',
    employee: null
  });
});

router.post('/admin/employees', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const formData = new URLSearchParams(req.body);
await axios.post(`${baseURL}/employees`, formData.toString(), {
  headers: {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/x-www-form-urlencoded'  // ✅ form-encoded
  }
});

    res.redirect('/admin/employees');
  } catch (err) {
    next(err);
  }
});

router.get('/admin/employees/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const { data } = await axios.get(`${baseURL}/employees/${req.params.id}`, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.render('admin/employee_form', {
      layout: 'layouts/admin',
      title: 'Sửa thông tin thợ',
      formTitle: 'Sửa thông tin thợ',
      formAction: `/admin/employees/${req.params.id}`,
      method: 'PATCH',
      employee: data
    });
  } catch (err) {
    next(err);
  }
});

router.patch('/admin/employees/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
const formData = new URLSearchParams(req.body);
await axios.patch(`${baseURL}/employees/${req.params.id}`, formData.toString(), {
  headers: {
    Authorization: `Bearer ${req.cookies?.token}`,
    'Content-Type': 'application/x-www-form-urlencoded'
  }
});
    res.redirect('/admin/employees');
  } catch (err) {
    next(err);
  }
});

router.delete('/admin/employees/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    await axios.delete(`${baseURL}/employees/${req.params.id}`, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.redirect('/admin/employees');
  } catch (err) {
    next(err);
  }
});


// ==================== QUẢN LÝ DỊCH VỤ ==================== //
router.get('/admin/services', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/services`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/services', {
      layout: 'layouts/admin',
      title: 'Quản lý Dịch vụ',
      services: data
    });
  } catch (err) {
    next(err);
  }
});

router.get('/admin/services/new', requireAdmin, (req, res) => {
  res.render('admin/service_form', {
    layout: 'layouts/admin',
    title: 'Thêm dịch vụ',
    formTitle: 'Thêm dịch vụ',
    formAction: '/admin/services',
    method: 'POST',
    service: null
  });
});

router.post('/admin/services', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.post(`${baseURL}/services`, req.body, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/services');
  } catch (err) {
    next(err);
  }
});

router.get('/admin/services/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/services/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/service_form', {
      layout: 'layouts/admin',
      title: 'Sửa dịch vụ',
      formTitle: 'Sửa dịch vụ',
      formAction: `/admin/services/${req.params.id}`,
      method: 'PATCH',
      service: data
    });
  } catch (err) {
    next(err);
  }
});

router.patch('/admin/services/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.patch(`${baseURL}/services/${req.params.id}`, req.body, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/services');
  } catch (err) {
    next(err);
  }
});

router.delete('/admin/services/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.delete(`${baseURL}/services/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/services');
  } catch (err) {
    next(err);
  }
});

module.exports = router;
