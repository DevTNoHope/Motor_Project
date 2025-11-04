const { validationResult } = require('express-validator');
const svc = require('../services/booking.service');

async function create(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ code:'VALIDATION_ERROR', errors: errors.array() });

    const data = await svc.createBooking(req.user.accId, req.body);
    res.status(201).json(data);
  } catch (e) { next(e); }
}

async function myList(req, res, next) {
  try { res.json(await svc.listMyBookings(req.user.accId)); }
  catch (e) { next(e); }
}

async function detail(req, res, next) {
  try { res.json(await svc.getMyBooking(req.user.accId, req.params.id)); }
  catch (e) { next(e); }
}

async function cancel(req, res, next) {
  try { res.json(await svc.cancelMyBooking(req.user.accId, req.params.id)); }
  catch (e) { next(e); }
}

module.exports = { create, myList, detail, cancel };
