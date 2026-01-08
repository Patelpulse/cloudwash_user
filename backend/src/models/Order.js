const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    firebaseUid: {
        type: String,
        required: false // Optional - only needed for Firebase sync
    },
    orderNumber: {
        type: String,
        required: true,
        unique: true
    },
    otp: {
        type: String,
        required: true
    },
    user: {
        name: { type: String, required: true },
        email: { type: String, required: true },
        phone: { type: String, required: true }
    },
    address: {
        label: String,
        name: String,
        phone: String,
        houseNumber: String,
        street: String,
        landmark: String,
        city: String,
        pincode: String,
        fullAddress: String
    },
    services: [{
        serviceId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Service'
        },
        name: { type: String, required: true },
        categoryName: String,
        subCategoryName: String,
        price: { type: Number, required: true },
        quantity: { type: Number, required: true, default: 1 },
        total: { type: Number, required: true }
    }],
    addons: [{
        addonId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Addon'
        },
        name: { type: String, required: true },
        price: { type: Number, required: true }
    }],
    priceSummary: {
        subtotal: { type: Number, required: true },
        tax: { type: Number, default: 0 },
        deliveryCharge: { type: Number, default: 0 },
        discount: { type: Number, default: 0 },
        total: { type: Number, required: true }
    },
    paymentMethod: {
        type: String,
        enum: ['UPI', 'Card', 'Cash', 'Wallet'],
        default: 'Cash'
    },
    paymentStatus: {
        type: String,
        enum: ['pending', 'paid', 'failed'],
        default: 'pending'
    },
    status: {
        type: String,
        enum: ['pending', 'confirmed', 'in-progress', 'completed', 'cancelled'],
        default: 'pending'
    },
    scheduledDate: Date,
    completedAt: Date,
    cancelledAt: Date,
    cancellationReason: String,
    notes: String
}, {
    timestamps: true
});

const Order = mongoose.model('Order', orderSchema);
module.exports = Order;
