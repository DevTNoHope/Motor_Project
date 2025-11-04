const { validationResult } = require('express-validator');
const svc = require('../services/booking.service');

async function diagnose(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code:'VALIDATION_ERROR', errors: errors.array() });

    const b = await svc.mechanicDiagnose(
      req.params.id,
      req.user.accId,
      {
        diagnosisNote: req.body.diagnosisNote,
        etaMin: req.body.etaMin,
        laborEstMin: req.body.laborEstMin,
        requiredParts: req.body.requiredParts
      }
    );
    res.json({ ok:true, id:b.id, status:b.status, end_dt:b.end_dt });
  } catch (e) { next(e); }
}

async function start(req, res, next) {
  try {
    const b = await svc.mechanicStart(req.params.id, req.user.accId);
    res.json({ ok:true, id:b.id, status:b.status });
  } catch (e) { next(e); }
}

async function complete(req, res, next) {
  try {
    const b = await svc.mechanicComplete(req.params.id, req.user.accId);
    res.json({ ok:true, id:b.id, status:b.status });
  } catch (e) { next(e); }
}

module.exports = { diagnose, start, complete };
