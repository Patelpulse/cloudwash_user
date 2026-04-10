const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const AboutUs = require('../models/AboutUs');
const Stats = require('../models/Stats');
const Footer = require('../models/Footer');
const StaticPage = require('../models/StaticPage');
const admin = require('../config/firebase');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Helper
const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        let cld_upload_stream = cloudinary.uploader.upload_stream(
            { folder: "cloudwash/webcontent" },
            (error, result) => {
                if (result) resolve(result);
                else reject(error);
            }
        );
        streamifier.createReadStream(buffer).pipe(cld_upload_stream);
    });
};

const getErrorMessage = (error) => {
    if (!error) return 'Unknown error';
    if (error instanceof Error) return error.message;
    if (typeof error === 'string') return error;
    return `${error.message ?? error.error ?? 'Unknown error'}`;
};

const toDataUrlFromFile = (file) => {
    const mimeType = file?.mimetype || 'image/png';
    const base64 = file?.buffer?.toString('base64') || '';
    return `data:${mimeType};base64,${base64}`;
};

const uploadImageWithFallback = async (
    file,
    { allowDataUrlFallback = false, fieldName = 'image' } = {}
) => {
    try {
        return await uploadFromBuffer(file.buffer);
    } catch (error) {
        if (!allowDataUrlFallback) {
            throw error;
        }

        const errorMessage = getErrorMessage(error);
        console.warn(
            `⚠️ Cloudinary upload failed for ${fieldName}. Using data URL fallback: ${errorMessage}`
        );
        return { secure_url: toDataUrlFromFile(file) };
    }
};

const normalizeTextInput = (value) => {
    if (value === undefined || value === null) return null;
    const text = `${value}`.trim();
    return text.length > 0 ? text : null;
};

const parseBooleanValue = (value, fallback = true) => {
    if (value === undefined || value === null) return fallback;
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value !== 0;
    const normalized = `${value}`.trim().toLowerCase();
    if (normalized === 'true' || normalized === '1') return true;
    if (normalized === 'false' || normalized === '0') return false;
    return fallback;
};

const syncAboutUsToFirestore = async (about) => {
    if (!admin.firestore) return;

    try {
        await admin
            .firestore()
            .collection('web_landing')
            .doc('about')
            .set(
                {
                    title: about.title,
                    subtitle: about.subtitle,
                    description: about.description,
                    experienceYears: about.experienceYears,
                    imageUrl: about.imageUrl,
                    points: Array.isArray(about.points) ? about.points : [],
                    isActive: about.isActive,
                    mongoId: about._id.toString(),
                    updatedAt: about.updatedAt
                        ? new Date(about.updatedAt).toISOString()
                        : new Date().toISOString(),
                    createdAt: about.createdAt
                        ? new Date(about.createdAt).toISOString()
                        : new Date().toISOString(),
                },
                { merge: true }
            );
    } catch (error) {
        console.error('⚠️ About Us Firestore sync failed:', error.message);
    }
};

const STATIC_PAGE_DEFAULTS = {
    terms: {
        title: 'Terms & Conditions',
        subtitle: 'Last Updated: April 2026',
        body:
            'Welcome to Cloud Wash. By using our website and app, you agree to these terms.\n\n' +
            '- Bookings are subject to professional availability.\n' +
            '- Cancellation fees may apply for late cancellations.\n' +
            '- Payments are processed securely.\n' +
            '- Cloud Wash is not liable for damages caused during service delivery.',
    },
    privacy: {
        title: 'Privacy Policy',
        subtitle: 'Last Updated: April 2026',
        body:
            'Your privacy is important to us. This policy outlines how we collect, use, and protect your data.\n\n' +
            '- We collect your name, phone number, and address to deliver services.\n' +
            '- Location data is used to match you with nearby professionals.\n' +
            '- We use industry-standard encryption to protect personal information.\n' +
            '- We do not sell your data to third parties.',
    },
    'child-protection': {
        title: 'Child Protection Policy',
        subtitle: 'Last Updated: April 2026',
        body:
            'At Cloud Wash, the safety and well-being of children are a priority.\n\n' +
            '- All professionals undergo identity verification and background checks.\n' +
            '- Service professionals are trained to interact respectfully in homes where children are present.\n' +
            '- We do not knowingly collect personal information from children under 18.\n' +
            '- Report any safety concern to our support team immediately.',
    },
    help: {
        title: 'Help & Support',
        subtitle: 'Last Updated: April 2026',
        body:
            'Need help with your order, account, or service? Our support team is here for you.\n\n' +
            '- Email us for quick assistance.\n' +
            '- Use the website contact form for service issues.\n' +
            '- Check your booking status in your account dashboard.\n' +
            '- Reach out for cancellations, rescheduling, or special requests.',
    },
    'refund-policy': {
        title: 'Refund Policy',
        subtitle: 'Last Updated: April 2026',
        body:
            'Our refund policy is designed to be fair and transparent.\n\n' +
            '- Refunds are considered for eligible prepaid cancellations.\n' +
            '- Service quality issues should be reported within 24 hours.\n' +
            '- Refunds may take 5-7 business days to process.\n' +
            '- Certain service fees may be non-refundable after dispatch.',
    },
};

const normalizeStaticPageSlug = (value) => {
    const slug = `${value || ''}`.trim().toLowerCase();
    if (
        slug === 'terms' ||
        slug === 'privacy' ||
        slug === 'child-protection' ||
        slug === 'help' ||
        slug === 'refund-policy'
    ) {
        return slug;
    }
    return null;
};

const getStaticPageDefaults = (slug) => {
    return STATIC_PAGE_DEFAULTS[slug] || {
        title: slug,
        subtitle: '',
        body: '',
    };
};

const buildStaticPageDocument = (slug, existingData = {}, body = {}) => {
    const defaults = getStaticPageDefaults(slug);
    const resolvedTitle = normalizeTextInput(body.title) ||
        normalizeTextInput(existingData.title) ||
        defaults.title;
    const resolvedSubtitle = body.subtitle !== undefined
        ? `${body.subtitle}`.trim()
        : `${existingData.subtitle ?? defaults.subtitle ?? ''}`.trim();
    const resolvedBody = body.body !== undefined
        ? `${body.body}`.trim()
        : body.content !== undefined
            ? `${body.content}`.trim()
            : `${existingData.body ?? existingData.content ?? defaults.body ?? ''}`.trim();
    const resolvedImageUrl = body.imageUrl !== undefined
        ? `${body.imageUrl}`.trim()
        : `${existingData.imageUrl ?? ''}`.trim();
    const resolvedIsActive = parseBooleanValue(
        body.isActive,
        parseBooleanValue(existingData.isActive, true)
    );

    return {
        slug,
        title: resolvedTitle,
        subtitle: resolvedSubtitle,
        body: resolvedBody,
        content: resolvedBody,
        imageUrl: resolvedImageUrl,
        isActive: resolvedIsActive,
        updatedAt: new Date().toISOString(),
        createdAt: existingData.createdAt || new Date().toISOString(),
    };
};

const syncStaticPageToFirestore = async (slug, page) => {
    try {
        if (!admin.firestore) return;

        let firestore;
        try {
            firestore = admin.firestore();
        } catch (firestoreError) {
            console.warn(
                `⚠️ Static page Firestore unavailable for ${slug}:`,
                firestoreError.message
            );
            return;
        }

        await firestore
            .collection('web_landing')
            .doc(`page_${slug}`)
            .set(
                {
                    slug,
                    title: page.title,
                    subtitle: page.subtitle,
                    body: page.body,
                    content: page.body,
                    imageUrl: page.imageUrl,
                    isActive: page.isActive,
                    updatedAt: page.updatedAt,
                    createdAt: page.createdAt,
                },
                { merge: true }
            );
    } catch (error) {
        console.error(`⚠️ Static page Firestore sync failed for ${slug}:`, error.message);
    }
};

// --- About Us ---
const getAboutUs = async (req, res) => {
    try {
        let about = await AboutUs.findOne({});
        if (!about) {
            about = await AboutUs.create({});
        }
        await syncAboutUsToFirestore(about);
        res.json(about);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateAboutUs = async (req, res) => {
    try {
        const { title, subtitle, description, experienceYears, points, isActive } = req.body;
        let about = await AboutUs.findOne({});
        if (!about) {
            about = await AboutUs.create({});
        }

        about.title = title || about.title;
        about.subtitle = subtitle || about.subtitle;
        about.description = description || about.description;
        const normalizedExperienceYears = Number.parseInt(
            `${experienceYears ?? ''}`.trim(),
            10
        );
        if (!Number.isNaN(normalizedExperienceYears)) {
            about.experienceYears = normalizedExperienceYears;
        }

        // Handle points array
        if (points) {
            try {
                about.points = typeof points === 'string' ? JSON.parse(points) : points;
            } catch (e) {
                about.points = points.split(',');
            }
        }

        about.isActive = parseBooleanValue(isActive, about.isActive);

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer);
            about.imageUrl = result.secure_url;
        }

        await about.save();
        await syncAboutUsToFirestore(about);
        res.json(about);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// --- Stats ---
const syncStatsToFirestore = async (stats) => {
    if (!admin.firestore) return;

    try {
        await admin
            .firestore()
            .collection('web_landing')
            .doc('stats')
            .set(
                {
                    happyClients: stats.happyClients,
                    totalBranches: stats.totalBranches,
                    totalCities: stats.totalCities,
                    totalOrders: stats.totalOrders,
                    isActive: stats.isActive,
                    mongoId: stats._id.toString(),
                    updatedAt: stats.updatedAt
                        ? new Date(stats.updatedAt).toISOString()
                        : new Date().toISOString(),
                    createdAt: stats.createdAt
                        ? new Date(stats.createdAt).toISOString()
                        : new Date().toISOString(),
                },
                { merge: true }
            );
    } catch (error) {
        console.error('⚠️ Stats Firestore sync failed:', error.message);
    }
};

const getStats = async (req, res) => {
    try {
        let stats = await Stats.findOne({});
        if (!stats) {
            stats = await Stats.create({});
        }
        await syncStatsToFirestore(stats);
        res.json(stats);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateStats = async (req, res) => {
    try {
        const {
            happyClients,
            totalBranches,
            totalCities,
            totalOrders,
            isActive,
        } = req.body || {};
        let stats = await Stats.findOne({});
        if (!stats) {
            stats = await Stats.create({});
        }

        const normalizedHappyClients = normalizeTextInput(happyClients);
        const normalizedTotalBranches = normalizeTextInput(totalBranches);
        const normalizedTotalCities = normalizeTextInput(totalCities);
        const normalizedTotalOrders = normalizeTextInput(totalOrders);

        if (normalizedHappyClients) stats.happyClients = normalizedHappyClients;
        if (normalizedTotalBranches) stats.totalBranches = normalizedTotalBranches;
        if (normalizedTotalCities) stats.totalCities = normalizedTotalCities;
        if (normalizedTotalOrders) stats.totalOrders = normalizedTotalOrders;
        stats.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : stats.isActive);

        const updatedStats = await stats.save();
        await syncStatsToFirestore(updatedStats);
        res.json(updatedStats);
    } catch (error) {
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// --- Footer ---
const normalizeLinks = (value, fallback = []) => {
    let parsed = value;

    if (typeof parsed === 'string') {
        const trimmed = parsed.trim();
        if (!trimmed) return fallback;
        try {
            parsed = JSON.parse(trimmed);
        } catch (_) {
            return fallback;
        }
    }

    if (!Array.isArray(parsed)) return fallback;

    return parsed
        .map((item) => ({
            label: `${item?.label ?? ''}`.trim(),
            route: `${item?.route ?? '/'}`.trim() || '/',
        }))
        .filter((item) => item.label || item.route !== '/');
};

const normalizeSocialLinks = (value, fallback = {}) => {
    let parsed = value;

    if (typeof parsed === 'string') {
        const trimmed = parsed.trim();
        if (!trimmed) return fallback;
        try {
            parsed = JSON.parse(trimmed);
        } catch (_) {
            return fallback;
        }
    }

    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
        return fallback;
    }

    return {
        facebook: `${parsed.facebook ?? ''}`.trim(),
        instagram: `${parsed.instagram ?? ''}`.trim(),
        email: `${parsed.email ?? ''}`.trim(),
        mail: `${parsed.mail ?? parsed.email ?? ''}`.trim(),
    };
};

const syncFooterToFirestore = async (footer) => {
    if (!admin.firestore) return;

    try {
        await admin
            .firestore()
            .collection('web_landing')
            .doc('footer')
            .set(
                {
                    description: footer.description,
                    phone: footer.phone,
                    email: footer.email,
                    address: footer.address,
                    copyright: footer.copyright,
                    exploreLinks: normalizeLinks(footer.exploreLinks, []),
                    serviceLinks: normalizeLinks(footer.serviceLinks, []),
                    policyLinks: normalizeLinks(footer.policyLinks, []),
                    socialLinks: normalizeSocialLinks(footer.socialLinks, {}),
                    mongoId: footer._id.toString(),
                    updatedAt: footer.updatedAt
                        ? new Date(footer.updatedAt).toISOString()
                        : new Date().toISOString(),
                    createdAt: footer.createdAt
                        ? new Date(footer.createdAt).toISOString()
                        : new Date().toISOString(),
                },
                { merge: true }
            );
    } catch (error) {
        console.error('⚠️ Footer Firestore sync failed:', error.message);
    }
};

const getFooter = async (req, res) => {
    try {
        let footer = await Footer.findOne({});
        if (!footer) {
            footer = await Footer.create({});
            await syncFooterToFirestore(footer);
        }
        res.json(footer);
    } catch (error) {
        console.error('Footer load failed:', error.message);
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateFooter = async (req, res) => {
    try {
        let footer = await Footer.findOne({});
        if (!footer) {
            footer = await Footer.create({});
        }

        const body = req.body || {};

        if (body.description !== undefined) {
            footer.description = `${body.description}`.trim();
        }
        if (body.phone !== undefined) {
            footer.phone = `${body.phone}`.trim();
        }
        if (body.email !== undefined) {
            footer.email = `${body.email}`.trim();
        }
        if (body.address !== undefined) {
            footer.address = `${body.address}`.trim();
        }
        if (body.copyright !== undefined) {
            footer.copyright = `${body.copyright}`.trim();
        }

        if (body.exploreLinks !== undefined) {
            footer.exploreLinks = normalizeLinks(body.exploreLinks, footer.exploreLinks);
        }
        if (body.serviceLinks !== undefined) {
            footer.serviceLinks = normalizeLinks(body.serviceLinks, footer.serviceLinks);
        }
        if (body.policyLinks !== undefined) {
            footer.policyLinks = normalizeLinks(body.policyLinks, footer.policyLinks);
        }
        if (body.socialLinks !== undefined) {
            footer.socialLinks = normalizeSocialLinks(body.socialLinks, footer.socialLinks);
        }

        await footer.save();
        await syncFooterToFirestore(footer);
        res.json(footer);
    } catch (error) {
        console.error('Footer update failed:', error.message);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// --- Static Pages ---
const getStaticPage = async (req, res) => {
    try {
        const slug = normalizeStaticPageSlug(req.params.slug);
        if (!slug) {
            return res.status(400).json({ message: 'Invalid static page slug' });
        }

        let staticPage = await StaticPage.findOne({ slug });
        if (!staticPage) {
            staticPage = await StaticPage.create(buildStaticPageDocument(slug, {}, {}));
        }

        const page = buildStaticPageDocument(
            slug,
            {
                ...getStaticPageDefaults(slug),
                ...(staticPage.toObject ? staticPage.toObject() : staticPage),
                slug,
            },
            {}
        );

        await syncStaticPageToFirestore(slug, page);

        return res.json(page);
    } catch (error) {
        console.error('Static page load failed:', error.message);
        return res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateStaticPage = async (req, res) => {
    try {
        const slug = normalizeStaticPageSlug(req.params.slug);
        if (!slug) {
            return res.status(400).json({ message: 'Invalid static page slug' });
        }

        let staticPage = await StaticPage.findOne({ slug });
        if (!staticPage) {
            staticPage = await StaticPage.create(buildStaticPageDocument(slug, {}, req.body || {}));
        }

        const existingData = staticPage.toObject ? staticPage.toObject() : staticPage;
        const page = buildStaticPageDocument(slug, existingData, req.body || {});

        const uploadedImageFile = req.file;
        if (uploadedImageFile) {
            const result = await uploadImageWithFallback(uploadedImageFile, {
                allowDataUrlFallback: true,
                fieldName: `static page ${slug} image`,
            });
            page.imageUrl = result.secure_url;
        }

        staticPage.slug = page.slug;
        staticPage.title = page.title;
        staticPage.subtitle = page.subtitle;
        staticPage.body = page.body;
        staticPage.imageUrl = page.imageUrl;
        staticPage.isActive = page.isActive;

        await staticPage.save();
        await syncStaticPageToFirestore(slug, page);
        return res.json(page);
    } catch (error) {
        console.error('Static page update failed:', error.message);
        return res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    getAboutUs,
    updateAboutUs,
    getStats,
    updateStats,
    getFooter,
    updateFooter,
    getStaticPage,
    updateStaticPage,
};
