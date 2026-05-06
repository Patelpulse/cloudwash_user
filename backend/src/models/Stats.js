const mongoose = require('mongoose');

const statsSchema = new mongoose.Schema({
    happyClients: {
        type: String,
        default: '500+ '
    },
    totalBranches: {
        type: String,
        default: '10+ '
    },
    totalCities: {
        type: String,
        default: '5+ '
    },
    totalOrders: {
        type: String,
        default: '1000+ '
    },
    isActive: {
        type: Boolean,
        default: true
    },
    appDownloadTag: {
        type: String,
        default: 'DOWNLOAD THE APP'
    },
    appDownloadTitle: {
        type: String,
        default: 'Your Personal Laundry\nManager in Your Pocket'
    },
    appDownloadSubtitle: {
        type: String,
        default: 'Book, track, and manage your laundry needs with a single tap. Join 50,000+ happy users today.'
    },
    appStoreUrl: {
        type: String,
        default: '#'
    },
    playStoreUrl: {
        type: String,
        default: '#'
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Stats', statsSchema);
