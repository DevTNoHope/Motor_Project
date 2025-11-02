const jwt = require('jsonwebtoken');

function requireAdmin(req, res, next) {
  const token = req.cookies?.token; // lưu trong cookie 'token'
  if (!token) return res.redirect('/admin/login');

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    if (payload.roleCode !== 'ADMIN') return res.redirect('/admin/login');
    // để EJS hiển thị tên admin
    res.locals.currentUser = { name: payload.name, role: payload.roleCode };
    next();
  } catch {
    return res.redirect('/admin/login');
  }
}

module.exports = { requireAdmin };
