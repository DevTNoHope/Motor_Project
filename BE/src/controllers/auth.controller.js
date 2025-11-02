const { validationResult } = require('express-validator');
const { registerUser, login } = require('../services/auth.service');

async function register(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code: 'VALIDATION_ERROR', errors: errors.array() });

    const result = await registerUser(req.body);
    return res.status(201).json(result);
  } catch (e) { next(e); }
}

async function loginCtrl(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code: 'VALIDATION_ERROR', errors: errors.array() });

    const result = await login(req.body);
    return res.json(result);
  } catch (e) { next(e); }
}

module.exports = { register, loginCtrl };
