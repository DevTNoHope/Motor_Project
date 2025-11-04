const service = require('../services/part.service');

async function getAll(req, res, next) {
  try {
    res.json(await service.getAll());
  } catch (e) { next(e); }
}

async function getById(req, res, next) {
  try {
    res.json(await service.getById(req.params.id));
  } catch (e) { next(e); }
}

async function create(req, res, next) {
  try {
    res.status(201).json(await service.create(req.body));
  } catch (e) { next(e); }
}

async function update(req, res, next) {
  try {
    res.json(await service.update(req.params.id, req.body));
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    res.json(await service.remove(req.params.id));
  } catch (e) { next(e); }
}

module.exports = { getAll, getById, create, update, remove };
