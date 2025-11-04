const { validationResult } = require('express-validator');
const svc = require('../services/workshift.service');

async function list(req, res, next) {
  try {
    const data = await svc.list({
      mechanicId: req.query.mechanicId ? parseInt(req.query.mechanicId,10) : undefined,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo
    });
    res.json(data);
  } catch (e) { next(e); }
}

async function create(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code:'VALIDATION_ERROR', errors: errors.array() });

    const data = await svc.create(req.body);
    res.status(201).json(data);
  } catch (e) { next(e); }
}

async function update(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code:'VALIDATION_ERROR', errors: errors.array() });

    const data = await svc.update(parseInt(req.params.id,10), req.body);
    res.json(data);
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const data = await svc.remove(parseInt(req.params.id,10));
    res.json(data);
  } catch (e) { next(e); }
}

module.exports = { list, create, update, remove };
