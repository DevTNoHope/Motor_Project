const svc = require('../services/slots.service');

async function getSlots(req, res, next) {
  try {
    const { mechanicId, date } = req.query;
    let serviceIds = req.query.serviceIds;
    // serviceIds có thể là '1,2,3' hoặc mảng
    if (typeof serviceIds === 'string') {
      serviceIds = serviceIds.split(',').map(s => parseInt(s,10)).filter(Boolean);
    } else if (Array.isArray(serviceIds)) {
      serviceIds = serviceIds.map(s => parseInt(s,10)).filter(Boolean);
    } else {
      serviceIds = [];
    }

    const mech = (mechanicId === undefined || mechanicId === null || mechanicId === '' || mechanicId === 'null')
      ? null : parseInt(mechanicId, 10);

    const data = await svc.slots({ mechanicId: mech, date, serviceIds });
    res.json(data);
  } catch (e) { next(e); }
}

module.exports = { getSlots };
