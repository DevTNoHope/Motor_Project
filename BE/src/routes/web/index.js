const router = require('express').Router();
router.get('/', (req, res) => res.redirect('/admin'));
router.use('/', require('./admin.web'));
module.exports = router;
