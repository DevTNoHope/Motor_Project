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

// ==================== QUẢN LÝ LOẠI PHỤ TÙNG ==================== //
router.get('/admin/part-types', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/part-types`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/part_types', {
      layout: 'layouts/admin',
      title: 'Quản lý Loại phụ tùng',
      partTypes: data
    });
  } catch (err) {
    next(err);
  }
});

router.get('/admin/part-types/new', requireAdmin, (req, res) => {
  res.render('admin/part_type_form', {
    layout: 'layouts/admin',
    title: 'Thêm loại phụ tùng',
    formTitle: 'Thêm loại phụ tùng',
    formAction: '/admin/part-types',
    method: 'POST',
    partType: null
  });
});

router.post('/admin/part-types', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const formData = new URLSearchParams(req.body);
    await axios.post(`${baseURL}/part-types`, formData.toString(), {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    res.redirect('/admin/part-types');
  } catch (err) {
    next(err);
  }
});

router.get('/admin/part-types/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/part-types/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/part_type_form', {
      layout: 'layouts/admin',
      title: 'Sửa loại phụ tùng',
      formTitle: 'Sửa loại phụ tùng',
      formAction: `/admin/part-types/${req.params.id}`,
      method: 'PATCH',
      partType: data
    });
  } catch (err) {
    next(err);
  }
});

router.patch('/admin/part-types/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const formData = new URLSearchParams(req.body);
    await axios.patch(`${baseURL}/part-types/${req.params.id}`, formData.toString(), {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    res.redirect('/admin/part-types');
  } catch (err) {
    next(err);
  }
});

router.delete('/admin/part-types/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.delete(`${baseURL}/part-types/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/part-types');
  } catch (err) {
    next(err);
  }
});
// ==================== QUẢN LÝ PHỤ TÙNG ==================== //
router.get('/admin/parts', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;

    const { data } = await axios.get(`${baseURL}/parts`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/parts', {
      layout: 'layouts/admin',
      title: 'Quản lý Phụ tùng',
      parts: data
    });
  } catch (err) {
    next(err);
  }
});

// Form thêm mới
router.get('/admin/parts/new', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;

    // ✅ Lấy danh sách loại phụ tùng cho dropdown
    const { data: partTypes } = await axios.get(`${baseURL}/part-types`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.render('admin/part_form', {
      layout: 'layouts/admin',
      title: 'Thêm phụ tùng',
      formTitle: 'Thêm phụ tùng',
      formAction: '/admin/parts',
      method: 'POST',
      part: null,
      partTypes
    });
  } catch (err) {
    next(err);
  }
});

// Tạo mới
router.post('/admin/parts', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.post(`${baseURL}/parts`, req.body, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/parts');
  } catch (err) {
    next(err);
  }
});

// Form sửa
router.get('/admin/parts/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;

    const [{ data: part }, { data: partTypes }] = await Promise.all([
      axios.get(`${baseURL}/parts/${req.params.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      }),
      axios.get(`${baseURL}/part-types`, {
        headers: { Authorization: `Bearer ${token}` }
      })
    ]);

    res.render('admin/part_form', {
      layout: 'layouts/admin',
      title: 'Sửa phụ tùng',
      formTitle: 'Sửa phụ tùng',
      formAction: `/admin/parts/${req.params.id}`,
      method: 'PATCH',
      part,
      partTypes
    });
  } catch (err) {
    next(err);
  }
});

// Cập nhật
router.patch('/admin/parts/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.patch(`${baseURL}/parts/${req.params.id}`, req.body, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/parts');
  } catch (err) {
    next(err);
  }
});

// Xóa
router.delete('/admin/parts/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.delete(`${baseURL}/parts/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/parts');
  } catch (err) {
    next(err);
  }
});

// ==================== QUẢN LÝ NHÀ CUNG CẤP ==================== //
router.get('/admin/suppliers', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/suppliers`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.render('admin/suppliers', {
      layout: 'layouts/admin',
      title: 'Quản lý Nhà cung cấp',
      suppliers: data
    });
  } catch (err) { next(err); }
});

router.get('/admin/suppliers/new', requireAdmin, (req, res) => {
  res.render('admin/supplier_form', {
    layout: 'layouts/admin',
    title: 'Thêm nhà cung cấp',
    formTitle: 'Thêm nhà cung cấp',
    formAction: '/admin/suppliers',
    method: 'POST',
    supplier: null
  });
});

router.post('/admin/suppliers', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    await axios.post(`${baseURL}/suppliers`, req.body, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.redirect('/admin/suppliers');
  } catch (err) { next(err); }
});

router.get('/admin/suppliers/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const { data } = await axios.get(`${baseURL}/suppliers/${req.params.id}`, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.render('admin/supplier_form', {
      layout: 'layouts/admin',
      title: 'Sửa nhà cung cấp',
      formTitle: 'Sửa nhà cung cấp',
      formAction: `/admin/suppliers/${req.params.id}`,
      method: 'PATCH',
      supplier: data
    });
  } catch (err) { next(err); }
});

router.patch('/admin/suppliers/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    await axios.patch(`${baseURL}/suppliers/${req.params.id}`, req.body, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.redirect('/admin/suppliers');
  } catch (err) { next(err); }
});

router.delete('/admin/suppliers/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    await axios.delete(`${baseURL}/suppliers/${req.params.id}`, {
      headers: { Authorization: `Bearer ${req.cookies?.token}` }
    });
    res.redirect('/admin/suppliers');
  } catch (err) { next(err); }
});


// ==================== QUẢN LÝ PHIẾU NHẬP HÀNG ==================== //
router.get('/admin/purchase-orders', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const { data } = await axios.get(`${baseURL}/purchase-orders`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.render('admin/purchase_orders', {
      layout: 'layouts/admin',
      title: 'Quản lý Phiếu nhập hàng',
      orders: data
    });
  } catch (err) { next(err); }
});

router.get('/admin/purchase-orders/new', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const [suppliersRes, partsRes] = await Promise.all([
      axios.get(`${baseURL}/suppliers`, { headers: { Authorization: `Bearer ${token}` } }),
      axios.get(`${baseURL}/parts`, { headers: { Authorization: `Bearer ${token}` } })
    ]);
    res.render('admin/purchase_order_form', {
      layout: 'layouts/admin',
      title: 'Thêm phiếu nhập hàng',
      formTitle: 'Tạo phiếu nhập hàng',
      formAction: '/admin/purchase-orders',
      method: 'POST',
      suppliers: suppliersRes.data,
      parts: partsRes.data,
      po: null
    });
  } catch (err) { next(err); }
});

router.post('/admin/purchase-orders', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;

    // Giải mã token JWT để lấy id người tạo
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const payload = {
      supplier_id: req.body.supplier_id,
      note: req.body.note,
      created_by: decoded.sub || decoded.accId, // ⚡ lấy id từ JWT
      items: req.body.items
    };

    await axios.post(`${baseURL}/purchase-orders`, payload, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.redirect('/admin/purchase-orders');
  } catch (err) { next(err); }
});


router.get('/admin/purchase-orders/:id/edit', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    const [poRes, suppliersRes, partsRes] = await Promise.all([
      axios.get(`${baseURL}/purchase-orders/${req.params.id}`, { headers: { Authorization: `Bearer ${token}` } }),
      axios.get(`${baseURL}/suppliers`, { headers: { Authorization: `Bearer ${token}` } }),
      axios.get(`${baseURL}/parts`, { headers: { Authorization: `Bearer ${token}` } })
    ]);
    res.render('admin/purchase_order_form', {
      layout: 'layouts/admin',
      title: 'Chi tiết phiếu nhập hàng',
      formTitle: 'Chi tiết phiếu nhập hàng',
      formAction: `/admin/purchase-orders/${req.params.id}`,
      method: 'PATCH',
      suppliers: suppliersRes.data,
      parts: partsRes.data,
      po: poRes.data
    });
  } catch (err) { next(err); }
});
// ✅ Cập nhật phiếu nhập hàng (chỉ khi còn ở trạng thái DRAFT)
router.patch('/admin/purchase-orders/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;

    await axios.patch(`${baseURL}/purchase-orders/${req.params.id}`, req.body, {
      headers: { Authorization: `Bearer ${token}` }
    });

    res.redirect('/admin/purchase-orders');
  } catch (err) {
    next(err);
  }
});

router.patch('/admin/purchase-orders/:id/receive', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.patch(`${baseURL}/purchase-orders/${req.params.id}/receive`, {}, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/purchase-orders');
  } catch (err) { next(err); }
});

router.delete('/admin/purchase-orders/:id', requireAdmin, async (req, res, next) => {
  try {
    const baseURL = `${req.protocol}://${req.get('host')}/api/v1`;
    const token = req.cookies?.token;
    await axios.delete(`${baseURL}/purchase-orders/${req.params.id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    res.redirect('/admin/purchase-orders');
  } catch (err) { next(err); }
});

module.exports = router;
