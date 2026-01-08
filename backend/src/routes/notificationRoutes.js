const express = require('express');
const router = express.Router();
const { getUserNotifications, markRead } = require('../controllers/notificationController');
const { protectUser } = require('../middleware/authMiddleware');

router.get('/', protectUser, getUserNotifications);
router.patch('/:id/read', protectUser, markRead);

module.exports = router;
