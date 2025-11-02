const { validationResult } = require('express-validator');
const { getProfile, updateProfile } = require('../services/me.service');

async function getMe(req, res, next) {
  try {
    const data = await getProfile(req.user.accId);
    res.json(data);
  } catch (e) { next(e); }
}

async function patchMe(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ code: 'VALIDATION_ERROR', errors: errors.array() });

    const data = await updateProfile(req.user.accId, req.body);
    res.json(data);
  } catch (e) { next(e); }
}

module.exports = { getMe, patchMe };
