const mongoose = require('mongoose');

const footerLinkSchema = new mongoose.Schema(
    {
        label: {
            type: String,
            default: '',
        },
        route: {
            type: String,
            default: '/',
        },
    },
    { _id: false }
);

const socialLinksSchema = new mongoose.Schema(
    {
        facebook: {
            type: String,
            default: '',
        },
        instagram: {
            type: String,
            default: '',
        },
        email: {
            type: String,
            default: '',
        },
        mail: {
            type: String,
            default: '',
        },
    },
    { _id: false }
);

const footerSchema = new mongoose.Schema(
    {
        description: {
            type: String,
            default:
                'Redefining premium garment care with technology and craftsmanship. Your wardrobe deserves nothing but the best.',
        },
        phone: {
            type: String,
            default: '+91 98765 43210',
        },
        email: {
            type: String,
            default: 'hello@cloudwash.com',
        },
        address: {
            type: String,
            default: 'Suite 402, Laundry Lane, Bangalore, KA 560001',
        },
        copyright: {
            type: String,
            default: () =>
                `© ${new Date().getFullYear()} Cloud Wash. Crafted with precision.`,
        },
        exploreLinks: {
            type: [footerLinkSchema],
            default: [],
        },
        serviceLinks: {
            type: [footerLinkSchema],
            default: [],
        },
        policyLinks: {
            type: [footerLinkSchema],
            default: [
                { label: 'Privacy Policy', route: '/privacy' },
                { label: 'Terms of Service', route: '/terms' },
                { label: 'Child Protection', route: '/child-protection' },
                { label: 'Sitemap', route: '/' },
            ],
        },
        socialLinks: {
            type: socialLinksSchema,
            default: () => ({
                facebook: '',
                instagram: '',
                email: '',
                mail: '',
            }),
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Footer', footerSchema);
