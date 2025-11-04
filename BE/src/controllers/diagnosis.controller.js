const { Diagnosis } = require('../models');

async function getByBooking(req, res, next) {
  try {
    const row = await Diagnosis.findOne({ where: { booking_id: req.params.bookingId } });
    if (!row) return res.status(404).json({ code: 'NOT_FOUND', message: 'No diagnosis for this booking' });
    res.json(row);
  } catch (e) { next(e); }
}

module.exports = { getByBooking };
