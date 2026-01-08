const Notification = require('../models/Notification');
const User = require('../models/User');
const admin = require('../config/firebase');

// Internal helper to send notification
const sendNotification = async (req, userId, title, message, type, orderId) => {
    try {
        const notification = await Notification.create({
            userId,
            title,
            message,
            type, // ensure type fits enum in model or update model if needed
            orderId,
            targetAudience: 'customers', // For compatibility
            isSent: true,
            sentAt: new Date()
        });

        // 1. Emit via Socket.IO
        if (req.io) {
            // Emitting to room named by userId
            req.io.to(userId.toString()).emit('notification', notification);
            console.log(`📡 Socket Notification sent to ${userId}: ${title}`);
        }

        // 2. Sync to Firebase Firestore for real-time mobile updates
        try {
            const user = await User.findById(userId);
            if (user && user.firebaseUid && admin.firestore) {
                await admin.firestore()
                    .collection('notifications')
                    .doc(notification._id.toString())
                    .set({
                        userId: user.firebaseUid,
                        mongoUserId: userId.toString(),
                        title,
                        message,
                        type,
                        orderId: orderId ? orderId.toString() : null,
                        isRead: false,
                        createdAt: notification.createdAt.toISOString(),
                        source: 'system'
                    });
                console.log(`🔥 Firebase Notification synced for ${user.firebaseUid}`);
            }
        } catch (firebaseError) {
            console.error("Firebase Sync Error:", firebaseError.message);
        }

    } catch (error) {
        console.error("Notification Error:", error);
    }
};

// API: Get notifications for logged in user
const getUserNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({ userId: req.user._id })
            .sort({ createdAt: -1 })
            .limit(50); // Cap at 50
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// API: Mark notification as read
const markRead = async (req, res) => {
    try {
        const { id } = req.params;
        const notification = await Notification.findById(id);

        if (!notification) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        if (notification.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'Not authorized' });
        }

        notification.isRead = true;
        await notification.save();

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    sendNotification,
    getUserNotifications,
    markRead
};
