const router = require("express").Router();
const { sequelize, Emp } = require("../../models");
const { verifyJWT, requireRole } = require("../../middlewares/auth");

// 🔒 Chỉ thợ sửa xe (MECHANIC) mới được gọi API này
router.use(verifyJWT, requireRole("MECHANIC"));

/**
 * 📊 API: GET /api/v1/mechanic/stats
 * Query params:
 *   - from: ngày bắt đầu (YYYY-MM-DD)
 *   - to: ngày kết thúc (YYYY-MM-DD)
 *   - groupBy: "day" | "week" | "month" (mặc định: month)
 */
router.get("/", async (req, res) => {
  try {
    const { from, to, groupBy = "month" } = req.query;

    // Lấy thông tin thợ dựa trên tài khoản đăng nhập
    const emp = await Emp.findOne({ where: { acc_id: req.user.accId } });
    if (!emp)
      return res.status(404).json({ error: "Không tìm thấy hồ sơ thợ sửa xe" });

    const mechanicId = emp.id;

    const whereDate =
      from && to ? `AND DATE(created_at) BETWEEN '${from}' AND '${to}'` : "";

    // 🧮 Tổng số đơn, doanh thu, và số đơn đã hoàn thành
    const [overview] = await sequelize.query(`
      SELECT
        COUNT(*) AS totalBookings,
        SUM(total_amount) AS totalRevenue,
        SUM(CASE WHEN status = 'DONE' THEN 1 ELSE 0 END) AS completedBookings
      FROM Bookings
      WHERE mechanic_id = ${mechanicId}
      ${whereDate};
    `);

    // 🗓 Gom theo ngày / tuần / tháng để hiển thị biểu đồ
    let dateFormat;
    if (groupBy === "day") dateFormat = "%Y-%m-%d";
    else if (groupBy === "week") dateFormat = "%Y-%u";
    else dateFormat = "%Y-%m"; // mặc định: theo tháng

    const [timeline] = await sequelize.query(`
      SELECT
        DATE_FORMAT(created_at, '${dateFormat}') AS period,
        COUNT(*) AS total,
        SUM(total_amount) AS revenue
      FROM Bookings
      WHERE mechanic_id = ${mechanicId}
      ${whereDate}
      GROUP BY period
      ORDER BY period ASC;
    `);

    // 🔧 5 dịch vụ được thực hiện nhiều nhất
    const [topServices] = await sequelize.query(`
      SELECT
        s.name,
        SUM(bs.qty) AS total
      FROM Booking_Service bs
      JOIN Services s ON s.id = bs.service_id
      JOIN Bookings b ON b.id = bs.booking_id
      WHERE b.mechanic_id = ${mechanicId}
      ${whereDate}
      GROUP BY s.id
      ORDER BY total DESC
      LIMIT 5;
    `);

    res.json({
      overview: overview[0] || {
        totalBookings: 0,
        totalRevenue: 0,
        completedBookings: 0,
      },
      timeline,
      topServices,
    });
  } catch (err) {
    console.error("🔥 /mechanic/stats error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
