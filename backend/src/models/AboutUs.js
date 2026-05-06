const mongoose = require('mongoose');

const aboutUsSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        default: 'About Us'
    },
    subtitle: {
        type: String,
        default: 'We are more than just a laundry service.'
    },
    description: {
        type: String,
        required: true,
        default: 'Cloud Wash is a premium laundry service provider committed to delivering the best care for your clothes.'
    },
    experienceYears: {
        type: Number,
        default: 5
    },
    imageUrl: {
        type: String,
        default: ''
    },
    points: [{
        type: String // e.g., "Quality Service", "Express Delivery"
    }],
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('AboutUs', aboutUsSchema);
