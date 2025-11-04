const { validationResult } = require('express-validator');
const svc = require('../services/booking.service');

async function approve(req, res, next) {
  try {
    const b = await svc.adminApprove(req.params.id);
    res.json({ ok: true, id: b.id, status: b.status });
  } catch (e) { next(e); }
}

async function assign(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code:'VALIDATION_ERROR', errors: errors.array() });

    const b = await svc.adminAssign(req.params.id, req.body.mechanicId);
    res.json({ ok: true, id: b.id, mechanic_id: b.mechanic_id });
  } catch (e) { next(e); }
}

module.exports = { approve, assign };
