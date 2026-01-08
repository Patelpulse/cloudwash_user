const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true,
    },
    message: {
        type: String,
        required: true,
    },
    type: {
        type: String,
        enum: ['info', 'success', 'warning', 'error', 'promotional', 'order_created', 'order_update'],
        default: 'info',
    },
    targetAudience: {
        type: String,
        enum: ['all', 'customers', 'providers'],
        default: 'all',
    },
    isActive: {
        type: Boolean,
        default: true,
    },
    scheduledFor: {
        type: Date,
        default: null,
    },
    isSent: {
        type: Boolean,
        default: false,
    },
    sentAt: {
        type: Date,
        default: null,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null,
    },
    orderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order',
        default: null,
    },
    isRead: {
        type: Boolean,
        default: false,
    },
}, {
    timestamps: true,
});

module.exports = mongoose.model('Notification', notificationSchema);
