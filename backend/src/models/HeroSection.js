const mongoose = require('mongoose');

const heroSectionSchema = new mongoose.Schema({
    tagline: {
        type: String,
        required: true,
        default: '✨ We Are Clino'
    },
    mainTitle: {
        type: String,
        required: true,
        default: 'Feel Your Way For\nFreshness'
    },
    description: {
        type: String,
        required: true,
        default: 'Experience the epitome of cleanliness with Clino. We provide top-notch cleaning services tailored to your needs, ensuring your spaces shine with perfection.'
    },
    buttonText: {
        type: String,
        required: true,
        default: 'Our Services'
    },
    imageUrl: {
        type: String,
        required: true,
        default: 'https://res.cloudinary.com/dssmutzly/image/upload/v1766830730/4d01db37af62132b8e554cfabce7767a_z7ioie.png'
    },
    logoUrl: {
        type: String,
        required: false,
        default: ''
    },
    logoHeight: {
        type: Number,
        required: false,
        default: 140,
    },
    youtubeUrl: {
        type: String,
        required: false,
        default: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('HeroSection', heroSectionSchema);
