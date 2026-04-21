const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const HeroSection = require('../models/HeroSection');
const admin = require('../config/firebase');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

const getErrorMessage = (error) => {
    if (!error) return 'Unknown upload error';
    if (typeof error === 'string') return error;
    if (error instanceof Error) return error.message;
    if (typeof error === 'object' && error.message) return error.message;
    try {
        return JSON.stringify(error);
    } catch (_) {
        return String(error);
    }
};

const DEFAULT_LOGO_BY_DEVICE = {
    phone: '',
    tablet: '',
    website: '',
};

const normalizeLogoDeviceType = (value) => {
    const normalized = `${value || ''}`.trim().toLowerCase();
    if (normalized === 'phone' || normalized === 'mobile') return 'phone';
    if (normalized === 'tablet' || normalized === 'tab') return 'tablet';
    if (normalized === 'website' || normalized === 'web' || normalized === 'desktop') {
        return 'website';
    }
    return null;
};

const getLogoByDevice = (heroSection) => {
    const raw = heroSection?.logoByDevice || {};
    const logoByDevice = {
        phone: `${raw.phone || ''}`.trim(),
        tablet: `${raw.tablet || ''}`.trim(),
        website: `${raw.website || ''}`.trim(),
    };
    const legacyLogo = `${heroSection?.logoUrl || ''}`.trim();
    if (legacyLogo && !logoByDevice.website) {
        logoByDevice.website = legacyLogo;
    }
    return logoByDevice;
};

const applyLogoByDevice = (heroSection, logoByDevice) => {
    heroSection.logoByDevice = {
        phone: `${logoByDevice.phone || ''}`.trim(),
        tablet: `${logoByDevice.tablet || ''}`.trim(),
        website: `${logoByDevice.website || ''}`.trim(),
    };
    heroSection.logoUrl = heroSection.logoByDevice.website || '';
};

const updateLogoForDevice = (heroSection, deviceType, logoValue) => {
    const nextLogoByDevice = getLogoByDevice(heroSection);
    nextLogoByDevice[deviceType] = `${logoValue || ''}`.trim();
    applyLogoByDevice(heroSection, nextLogoByDevice);
};

const normalizeTextInput = (value) => {
    if (value === undefined || value === null) return null;
    const text = `${value}`.trim();
    return text.length > 0 ? text : null;
};

const normalizeNumberInput = (value) => {
    if (value === undefined || value === null) return null;
    const text = `${value}`.trim();
    if (!text) return null;
    const parsed = Number(text);
    return Number.isFinite(parsed) ? parsed : null;
};

// Helper to upload to Cloudinary
const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        if (!buffer) {
            reject(new Error('Missing file buffer'));
            return;
        }

        const cld_upload_stream = cloudinary.uploader.upload_stream(
            { folder: "cloudwash/hero" },
            (error, result) => {
                if (result?.secure_url) {
                    resolve(result);
                } else {
                    reject(
                        error || new Error('Cloudinary upload failed without result')
                    );
                }
            }
        );

        const readStream = streamifier.createReadStream(buffer);
        readStream.on('error', reject);
        cld_upload_stream.on('error', reject);
        readStream.pipe(cld_upload_stream);
    });
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

const findLatestHeroSection = () => {
    return HeroSection.findOne({}).sort({
        updatedAt: -1,
        createdAt: -1,
        _id: -1,
    });
};

const syncHeroSectionToFirestore = async (heroSection) => {
    if (!admin.firestore) return;

    try {
        const logoByDevice = getLogoByDevice(heroSection);
        await admin
            .firestore()
            .collection('web_landing')
            .doc('hero')
            .set(
                {
                    tagline: heroSection.tagline,
                    mainTitle: heroSection.mainTitle,
                    description: heroSection.description,
                    buttonText: heroSection.buttonText,
                    titleFontFamily: heroSection.titleFontFamily || 'Playfair Display',
                    bodyFontFamily: heroSection.bodyFontFamily || 'Inter',
                    titleFontSize: heroSection.titleFontSize || 64,
                    descriptionFontSize: heroSection.descriptionFontSize || 18,
                    titleColor: heroSection.titleColor || '#1E293B',
                    descriptionColor: heroSection.descriptionColor || '#64748B',
                    accentColor: heroSection.accentColor || '#3B82F6',
                    buttonTextColor: heroSection.buttonTextColor || '#FFFFFF',
                    imageUrl: heroSection.imageUrl,
                    logoUrl: logoByDevice.website || '',
                    logoByDevice,
                    logoHeight: heroSection.logoHeight || 140,
                    youtubeUrl: heroSection.youtubeUrl || '',
                    isActive: heroSection.isActive,
                    mongoId: heroSection._id.toString(),
                    updatedAt: new Date().toISOString(),
                },
                { merge: true }
            );
    } catch (error) {
        console.error('⚠️ Hero Firestore sync failed:', error.message);
    }
};

// Get hero section (returns first/only document or creates one)
const getHeroSection = async (req, res) => {
    try {
        let heroSection = await findLatestHeroSection();

        // If no hero section exists, create default one
        if (!heroSection) {
            heroSection = await HeroSection.create({
                tagline: '✨ We Are Clino',
                mainTitle: 'Feel Your Way For\nFreshness',
                description: 'Experience the epitome of cleanliness with Clino. We provide top-notch cleaning services tailored to your needs, ensuring your spaces shine with perfection.',
                buttonText: 'Our Services',
                titleFontFamily: 'Playfair Display',
                bodyFontFamily: 'Inter',
                titleFontSize: 64,
                descriptionFontSize: 18,
                titleColor: '#1E293B',
                descriptionColor: '#64748B',
                accentColor: '#3B82F6',
                buttonTextColor: '#FFFFFF',
                imageUrl: 'https://res.cloudinary.com/dssmutzly/image/upload/v1766830730/4d01db37af62132b8e554cfabce7767a_z7ioie.png',
                logoUrl: '',
                logoByDevice: DEFAULT_LOGO_BY_DEVICE,
                logoHeight: 140,
                youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                isActive: true
            });

            await syncHeroSectionToFirestore(heroSection);
        }

        res.json(heroSection);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// Update hero section
const updateHeroSection = async (req, res) => {
    try {
        const {
            tagline,
            mainTitle,
            description,
            buttonText,
            titleFontFamily,
            bodyFontFamily,
            titleFontSize,
            descriptionFontSize,
            titleColor,
            descriptionColor,
            accentColor,
            buttonTextColor,
            youtubeUrl,
            logoUrl,
            logoHeight,
            logoDeviceType,
            isActive,
        } = req.body;

        let heroSection = await findLatestHeroSection();

        if (!heroSection) {
            heroSection = await HeroSection.create({ logoByDevice: DEFAULT_LOGO_BY_DEVICE });
        }

        const normalizedLogoDeviceType = normalizeLogoDeviceType(logoDeviceType);

        // Update fields
        heroSection.tagline = tagline || heroSection.tagline;
        heroSection.mainTitle = mainTitle || heroSection.mainTitle;
        heroSection.description = description || heroSection.description;
        heroSection.buttonText = buttonText || heroSection.buttonText;
        const normalizedTitleFontFamily = normalizeTextInput(titleFontFamily);
        if (normalizedTitleFontFamily) {
            heroSection.titleFontFamily = normalizedTitleFontFamily;
        }
        const normalizedBodyFontFamily = normalizeTextInput(bodyFontFamily);
        if (normalizedBodyFontFamily) {
            heroSection.bodyFontFamily = normalizedBodyFontFamily;
        }
        const normalizedTitleFontSize = normalizeNumberInput(titleFontSize);
        if (normalizedTitleFontSize !== null) {
            heroSection.titleFontSize = normalizedTitleFontSize;
        }
        const normalizedDescriptionFontSize = normalizeNumberInput(
            descriptionFontSize
        );
        if (normalizedDescriptionFontSize !== null) {
            heroSection.descriptionFontSize = normalizedDescriptionFontSize;
        }
        const normalizedTitleColor = normalizeTextInput(titleColor);
        if (normalizedTitleColor) {
            heroSection.titleColor = normalizedTitleColor;
        }
        const normalizedDescriptionColor = normalizeTextInput(descriptionColor);
        if (normalizedDescriptionColor) {
            heroSection.descriptionColor = normalizedDescriptionColor;
        }
        const normalizedAccentColor = normalizeTextInput(accentColor);
        if (normalizedAccentColor) {
            heroSection.accentColor = normalizedAccentColor;
        }
        const normalizedButtonTextColor = normalizeTextInput(buttonTextColor);
        if (normalizedButtonTextColor) {
            heroSection.buttonTextColor = normalizedButtonTextColor;
        }
        if (logoUrl !== undefined) {
            if (normalizedLogoDeviceType) {
                updateLogoForDevice(heroSection, normalizedLogoDeviceType, logoUrl);
            } else {
                updateLogoForDevice(heroSection, 'website', logoUrl);
            }
        }
        if (logoHeight !== undefined && logoHeight !== '') {
            const parsedHeight = Number(logoHeight);
            if (Number.isFinite(parsedHeight)) {
                heroSection.logoHeight = parsedHeight;
            }
        }
        if (youtubeUrl !== undefined) heroSection.youtubeUrl = youtubeUrl;
        heroSection.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : heroSection.isActive);

        const heroImageFile = req.files?.image?.[0] || req.file;
        const logoImageFile = req.files?.logo?.[0];

        // Upload new hero image if provided
        if (heroImageFile) {
            const result = await uploadImageWithFallback(heroImageFile, {
                allowDataUrlFallback: true,
                fieldName: 'hero image',
            });
            heroSection.imageUrl = result.secure_url;
        }

        // Upload new logo if provided
        if (logoImageFile) {
            const result = await uploadImageWithFallback(logoImageFile, {
                allowDataUrlFallback: true,
                fieldName: 'logo',
            });
            updateLogoForDevice(
                heroSection,
                normalizedLogoDeviceType || 'website',
                result.secure_url
            );
        }

        const updatedHeroSection = await heroSection.save();
        await syncHeroSectionToFirestore(updatedHeroSection);
        res.json(updatedHeroSection);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: getErrorMessage(error) });
    }
};

module.exports = {
    getHeroSection,
    updateHeroSection
};
