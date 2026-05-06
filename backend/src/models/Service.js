const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    category: {
        type: String,
        ref: 'Category',
        required: true,
    },
    subCategory: {
        type: String,
        ref: 'SubCategory',
        required: false, // Optional for now to support backward compatibility
    },
    price: {
        type: Number,
        required: true,
    },
    // Add a dedicated duration field (in minutes, for example)
    duration: {
        type: Number,
        required: true,
    },
    description: {
        type: String,
        required: true,
    },
    isActive: {
        type: Boolean,
        default: true,
    },
    imageUrl: {
        type: String,
        required: false,
        default: '',
    },
    displayOrder: {
        type: Number,
        default: 100000,
        index: true,
    },
}, {
    timestamps: true,
});

module.exports = mongoose.model('Service', serviceSchema);
