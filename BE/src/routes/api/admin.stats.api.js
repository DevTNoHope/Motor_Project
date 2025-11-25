const router = require("express").Router();
const { Booking, sequelize } = require("../../models");

router.get("/stats", async (req, res) => {
  try {
    // Tổng số đơn
    const totalBookings = await Booking.count();

    // Tổng doanh thu
    const totalRevenue = await Booking.sum("total_amount");

    // Đơn hoàn thành
    const completedBookings = await Booking.count({
      where: { status: "DONE" }
    });

    // Doanh thu theo tháng
    const [monthly] = await sequelize.query(`
      SELECT 
          DATE_FORMAT(created_at, '%Y-%m') AS month,
          SUM(total_amount) AS revenue
      FROM ${Booking.getTableName()}
      GROUP BY month
      ORDER BY month ASC;
    `);

    // 🔥 TOP 5 DỊCH VỤ ĐƯỢC ĐẶT NHIỀU NHẤT
    const [topServices] = await sequelize.query(`
      SELECT 
          s.name,
          SUM(bs.qty) AS total
      FROM Booking_Service bs
      JOIN Services s ON s.id = bs.service_id
      GROUP BY s.id
      ORDER BY total DESC
      LIMIT 5;
    `);

    res.json({
      totalBookings,
      totalRevenue,
      completedBookings,
      monthly,
      topServices
    });

  } catch (err) {
    console.error("🔥 /admin/stats error:", err);
    res.status(500).json({ error: err.message });
  }
});
router.get("/range", async (req, res) => {
  try {
    const { from, to } = req.query;

    if (!from || !to) return res.status(400).json({ error: "Missing date range" });

    const [rows] = await sequelize.query(`
      SELECT 
        COUNT(*) AS count,
        SUM(total_amount) AS revenue
      FROM Bookings
      WHERE DATE(created_at) BETWEEN :from AND :to
    `, {
      replacements: { from, to }
    });

    res.json({
      count: rows[0].count || 0,
      revenue: rows[0].revenue || 0
    });

  } catch (err) {
    console.error("range stats error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
