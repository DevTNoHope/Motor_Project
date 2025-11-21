// services/notification.service.js
const { getIO } = require('../socket');
const { Notification, Booking, User, Acc } = require('../models'); // chỉnh path cho đúng

async function createNotification({ userId, type, booking, title, body }) {
  if (!userId) return;

  const notification = await Notification.create({
    user_id: userId,
    type,
    booking_id: booking ? booking.id : null,
    title,
    body,
  });

  // 🔔 Emit realtime qua Socket.IO
  try {
    const io = getIO();

    const user = await User.findByPk(userId, { attributes: ['acc_id'] });
    if (!user || !user.acc_id) {
      console.warn('No acc_id found for user', userId);
      return notification;
    }

    const accId = user.acc_id;

    io.to(`user-${accId}`).emit('notification:new', {
      id: notification.id,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      booking_id: notification.booking_id,
      is_read: notification.is_read,
      created_at: notification.created_at,
    });
    console.log('Emit notification:new to user', userId);
  } catch (e) {
    console.error('Emit notification socket error:', e.message);
  }

  return notification;
}


/**
 * Tạo thông báo liên quan đến booking cho khách
 * booking: instance Booking đã có include User/Acc nếu cần
 */
async function createBookingNotification(type, booking, options = {}) {
  if (!booking) return;

  const userId = booking.user_id; // từ Booking model

  // Có thể custom title/body theo từng type
  let title = options.title;
  let body = options.body;

  const startTime = booking.start_dt?.toLocaleString?.() || '';

  switch (type) {
    case 'BOOKING_CREATED':
      title ||= 'Đặt lịch thành công';
      body ||= `Bạn đã đặt lịch sửa xe vào ${startTime}.`;
      break;
    case 'BOOKING_CANCELLED':
      title ||= 'Bạn đã hủy lịch hẹn';
      body ||= `Lịch sửa xe lúc ${startTime} đã được bạn hủy.`;
      break;
    case 'BOOKING_APPROVED':
      title ||= 'Lịch hẹn đã được xác nhận';
      body ||= `Lịch sửa xe lúc ${startTime} đã được sửa xe xác nhận.`;
      break;
    case 'BOOKING_REJECTED':
      title ||= 'Lịch hẹn bị từ chối';
      body ||= `Lịch sửa xe lúc ${startTime} đã bị từ chối.`;
      break;
    case 'BOOKING_IN_DIAGNOSIS':
      title ||= 'Xe đang được kiểm tra';
      body ||= `Thợ đang chẩn đoán tình trạng xe của bạn.`;
      break;
    case 'BOOKING_STARTED':
      title ||= 'Bắt đầu sửa xe';
      body ||= `Thợ đã bắt đầu sửa xe của bạn.`;
      break;
    case 'BOOKING_IN_PROGRESS':
      title ||= 'Xe đang được sửa';
      body ||= `Xe của bạn đang trong quá trình sửa chữa.`;
      break;
    case 'BOOKING_DONE':
      title ||= 'Hoàn thành sửa xe';
      body ||= `Xe của bạn đã được sửa xong. Vui lòng kiểm tra và thanh toán.`;
      break;
    case 'REVIEW_CREATED':
      title ||= 'Phiếu đánh giá đã được tạo';
      body ||= `Thợ đã lập phiếu đánh giá cho lần sửa xe này.`;
      break;
    default:
      title ||= 'Cập nhật lịch hẹn';
      body ||= 'Lịch hẹn sửa xe của bạn vừa được cập nhật.';
  }

  return createNotification({ userId, type, booking, title, body });
}

async function getUserNotifications(userId, { limit = 20, offset = 0 } = {}) {
  return Notification.findAll({
    where: { user_id: userId },
    order: [['created_at', 'DESC']],
    limit,
    offset,
  });
}

async function markNotificationRead(id, userId) {
  const noti = await Notification.findOne({ where: { id, user_id: userId } });
  if (!noti) return null;
  noti.is_read = true;
  await noti.save();
  return noti;
}

async function markAllRead(userId) {
  await Notification.update(
    { is_read: true },
    { where: { user_id: userId, is_read: false } }
  );
}

module.exports = {
  createNotification,
  createBookingNotification,
  getUserNotifications,
  markNotificationRead,
  markAllRead,
};
