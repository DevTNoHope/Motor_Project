const nodemailer = require("nodemailer");

// ⚙️ Cấu hình SMTP — bạn thay bằng tài khoản Gmail hoặc Mail Server riêng
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.MAIL_USER, // ví dụ: "garagebooking@gmail.com"
    pass: process.env.MAIL_PASS, // app password (không phải mật khẩu thật)
  },
});

/**
 * Gửi email thông báo đặt lịch
 */
async function sendBookingEmail(to, { name, vehicle, startTime }) {
  if (!to) return;

  const html = `
    <h2>📅 Xác nhận đặt lịch sửa xe</h2>
    <p>Xin chào <strong>${name}</strong>,</p>
    <p>Bạn đã đặt lịch sửa xe <b>${vehicle}</b> thành công.</p>
    <p><b>Thời gian:</b> ${startTime}</p>
    <p>Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi ❤️</p>
    <hr/>
    <p><i>Dịch Vụ sửa xe 3T Team</i></p>
  `;

  await transporter.sendMail({
    from: `"Dịch Vụ Sửa Xe 3T " <${process.env.MAIL_USER}>`,
    to,
    subject: "Xác nhận đặt lịch sửa xe thành công ✅",
    html,
  });
}

module.exports = { sendBookingEmail };
