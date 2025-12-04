const router = require("express").Router();
const { Booking, sequelize } = require("../../models");

// ================== TỔNG QUAN DASHBOARD ==================
router.get("/stats", async (req, res) => {
  try {
    // Tổng số đơn
    const totalBookings = await Booking.count();

    // Tổng doanh thu
    const totalRevenue = await Booking.sum("total_amount");

    // Đơn hoàn thành
    const completedBookings = await Booking.count({
      where: { status: "DONE" },
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

    // TOP 5 DỊCH VỤ ĐƯỢC ĐẶT NHIỀU NHẤT
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
      topServices,
    });
  } catch (err) {
    console.error("🔥 /admin/stats error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ================== API BIỂU ĐỒ ĐA CHẾ ĐỘ ==================
router.get("/chart", async (req, res) => {
  try {
    const { mode = "monthly", from, to } = req.query;
    const tableName = Booking.getTableName();

    let query = "";
    const replacements = {};

    switch (mode) {
      case "daily":
        query = `
          SELECT 
            DATE(created_at) AS label,
            COUNT(*) AS count,
            SUM(total_amount) AS revenue
          FROM ${tableName}
          GROUP BY DATE(created_at)
          ORDER BY DATE(created_at) ASC;
        `;
        break;

      case "weekly":
        // ISO week: năm-tuần
        query = `
          SELECT 
            DATE_FORMAT(created_at, '%x-W%v') AS label,
            COUNT(*) AS count,
            SUM(total_amount) AS revenue
          FROM ${tableName}
          GROUP BY DATE_FORMAT(created_at, '%x-W%v')
          ORDER BY label ASC;
        `;
        break;

      case "monthly":
        query = `
          SELECT 
            DATE_FORMAT(created_at, '%Y-%m') AS label,
            COUNT(*) AS count,
            SUM(total_amount) AS revenue
          FROM ${tableName}
          GROUP BY DATE_FORMAT(created_at, '%Y-%m')
          ORDER BY label ASC;
        `;
        break;

      case "quarterly":
        query = `
          SELECT 
            label,
            COUNT(*) AS count,
            SUM(total_amount) AS revenue
          FROM (
            SELECT 
              CONCAT(YEAR(created_at), '-Q', QUARTER(created_at)) AS label,
              total_amount
            FROM ${tableName}
          ) AS t
          GROUP BY label
          ORDER BY label ASC;
        `;
        break;

      case "range":
        if (!from || !to) {
          return res
            .status(400)
            .json({ error: "Missing date range (from, to)" });
        }
        replacements.from = from;
        replacements.to = to;

        query = `
          SELECT 
            DATE(created_at) AS label,
            COUNT(*) AS count,
            SUM(total_amount) AS revenue
          FROM ${tableName}
          WHERE DATE(created_at) BETWEEN :from AND :to
          GROUP BY DATE(created_at)
          ORDER BY DATE(created_at) ASC;
        `;
        break;

      default:
        return res.status(400).json({ error: "Invalid mode" });
    }

    const [rows] = await sequelize.query(query, { replacements });

    const labels = rows.map((r) => r.label);
    const values = rows.map((r) => Number(r.revenue || 0));
    const totalCount = rows.reduce((sum, r) => sum + Number(r.count || 0), 0);
    const totalRevenue = rows.reduce(
      (sum, r) => sum + Number(r.revenue || 0),
      0
    );

    res.json({
      mode,
      labels,
      values,
      count: totalCount,
      revenue: totalRevenue,
    });
  } catch (err) {
    console.error("chart stats error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ================== RANGE  ==================
router.get("/range", async (req, res) => {
  try {
    const { from, to } = req.query;

    if (!from || !to)
      return res.status(400).json({ error: "Missing date range" });

    const [rows] = await sequelize.query(
      `
      SELECT 
        COUNT(*) AS count,
        SUM(total_amount) AS revenue
      FROM ${Booking.getTableName()}
      WHERE DATE(created_at) BETWEEN :from AND :to
    `,
      {
        replacements: { from, to },
      }
    );

    res.json({
      count: rows[0].count || 0,
      revenue: rows[0].revenue || 0,
    });
  } catch (err) {
    console.error("range stats error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
