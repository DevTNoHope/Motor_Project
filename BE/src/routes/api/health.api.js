const router = require('express').Router();
const { testConnection } = require('../../config/db');
const { Role } = require('../../models');

router.get('/db', async (req, res, next) => {
  try {
    await testConnection();

    // thử SELECT Roles (nếu chưa seed Roles thì endpoint vẫn ok nhưng mảng rỗng)
    const roles = await Role.findAll({ limit: 5 });
    res.json({ ok: true, roles });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
