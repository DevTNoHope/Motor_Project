// controllers/notification.controller.js
const { User } = require('../models');
const notificationService = require('../services/notification.service');

/**
 * Lấy danh sách thông báo của user hiện tại
 * Giả sử middleware auth đã gắn acc_id vào req.acc.id
 */
async function getMyNotifications(req, res, next) {
  try {
    const accId = req.user.accId; // tuỳ bạn đang lưu gì trong req
    const user = await User.findOne({ where: { acc_id: accId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const limit = parseInt(req.query.limit, 10) || 20;
    const offset = parseInt(req.query.offset, 10) || 0;

    const notifications = await notificationService.getUserNotifications(user.id, { limit, offset });

    res.json(notifications);
  } catch (err) {
    next(err);
  }
}

async function markNotificationRead(req, res, next) {
  try {
    const accId = req.user.accId;
    const user = await User.findOne({ where: { acc_id: accId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const id = req.params.id;
    const noti = await notificationService.markNotificationRead(id, user.id);
    if (!noti) return res.status(404).json({ message: 'Notification not found' });

    res.json(noti);
  } catch (err) {
    next(err);
  }
}

async function markAllNotificationsRead(req, res, next) {
  try {
    const accId = req.user.accId;
    const user = await User.findOne({ where: { acc_id: accId } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    await notificationService.markAllRead(user.id);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead,
};
