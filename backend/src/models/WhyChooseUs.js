const mongoose = require('mongoose');

const whyChooseUsSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    iconUrl: {
        type: String,
        required: false,
        default: ''
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('WhyChooseUs', whyChooseUsSchema);
