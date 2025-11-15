const { Diagnosis, Part } = require('../models');

async function getByBooking(req, res, next) {
  try {
    const diag = await Diagnosis.findOne({ where: { booking_id: req.params.bookingId } });
    if (!diag) return res.status(404).json({ code: 'NOT_FOUND', message: 'No diagnosis for this booking' });

    const requiredParts = diag.required_parts || [];
    const partIds = requiredParts.map(p => p.partId);

    let parts = [];
    if (partIds.length) {
      parts = await Part.findAll({ where: { id: partIds } });
    }

    const partsMap = {};
    parts.forEach(p => { partsMap[p.id] = p; });

    const requiredPartsWithDetail = requiredParts.map(p => ({
      ...p,
      part: partsMap[p.partId] ? {
        id: partsMap[p.partId].id,
        name: partsMap[p.partId].name,
        price: partsMap[p.partId].price,
        unit: partsMap[p.partId].unit,
      } : null,
    }));

    res.json({
      ...diag.toJSON(),
      required_parts: requiredPartsWithDetail,
    });
  } catch (e) { next(e); }
}

module.exports = { getByBooking };
