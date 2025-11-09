const { validationResult } = require('express-validator');
const svc = require('../services/booking.service');

async function list(req, res, next) {
  try {
    const data = await svc.adminListBookings({
      status: req.query.status,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo,
      mechanicId: req.query.mechanicId ? parseInt(req.query.mechanicId,10) : undefined,
      page: req.query.page || 1,
      size: req.query.size || 20
    });
    res.json(data);
  } catch (e) { next(e); }
}

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

async function cancel(req, res, next) {
  try {
    const b = await svc.adminCancel(req.params.id, req.body.reason);
    res.json(b);
  } catch (e) { next(e); }
}
module.exports = { list, approve, assign, cancel };