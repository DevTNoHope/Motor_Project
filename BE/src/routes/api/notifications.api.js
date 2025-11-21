// routes/notifications.api.js
const express = require('express');
const router = express.Router();
const {verifyJWT} = require('../../middlewares/auth'); // sửa đúng đường dẫn
const notificationController = require('../../controllers/notification.controller');

router.use(verifyJWT); // hoặc middleware bạn đang dùng

router.get('/me', notificationController.getMyNotifications);
router.patch('/:id/read', notificationController.markNotificationRead);
router.post('/mark-all-read', notificationController.markAllNotificationsRead);

module.exports = router;
