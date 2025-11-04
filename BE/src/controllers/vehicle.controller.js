const { validationResult } = require('express-validator');
const svc = require('../services/vehicle.service');

async function list(req, res, next) {
  try {
    const data = await svc.listMyVehicles(req.user.accId);
    res.json(data);
  } catch (e) { next(e); }
}

async function detail(req, res, next) {
  try {
    const data = await svc.getMyVehicle(req.user.accId, req.params.id);
    res.json(data);
  } catch (e) { next(e); }
}

async function create(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code: 'VALIDATION_ERROR', errors: errors.array() });
    const data = await svc.createMyVehicle(req.user.accId, req.body);
    res.status(201).json(data);
  } catch (e) { next(e); }
}

async function update(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code: 'VALIDATION_ERROR', errors: errors.array() });
    const data = await svc.updateMyVehicle(req.user.accId, req.params.id, req.body);
    res.json(data);
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const data = await svc.deleteMyVehicle(req.user.accId, req.params.id);
    res.json(data);
  } catch (e) { next(e); }
}

module.exports = { list, detail, create, update, remove };
