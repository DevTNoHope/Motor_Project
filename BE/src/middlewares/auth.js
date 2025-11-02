const jwt = require('jsonwebtoken');

function verifyJWT(req, res, next) {
  const auth = req.headers.authorization || '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : null;
  if (!token) return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Missing Bearer token' });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload; // { sub, roleCode, accId, name }
    next();
  } catch (e) {
    return res.status(401).json({ code: 'INVALID_TOKEN', message: 'Token invalid or expired' });
  }
}

function requireRole(...roleCodes) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Login required' });
    if (!roleCodes.includes(req.user.roleCode))
      return res.status(403).json({ code: 'FORBIDDEN', message: 'Insufficient role' });
    next();
  };
}

module.exports = { verifyJWT, requireRole };
