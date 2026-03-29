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

const syncHeroSectionToFirestore = async (heroSection) => {
    if (!admin.firestore) return;

    try {
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
                    imageUrl: heroSection.imageUrl,
                    logoUrl: heroSection.logoUrl || '',
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
        let heroSection = await HeroSection.findOne({});

        // If no hero section exists, create default one
        if (!heroSection) {
            heroSection = await HeroSection.create({
                tagline: '✨ We Are Clino',
                mainTitle: 'Feel Your Way For\nFreshness',
                description: 'Experience the epitome of cleanliness with Clino. We provide top-notch cleaning services tailored to your needs, ensuring your spaces shine with perfection.',
                buttonText: 'Our Services',
                imageUrl: 'https://res.cloudinary.com/dssmutzly/image/upload/v1766830730/4d01db37af62132b8e554cfabce7767a_z7ioie.png',
                logoUrl: '',
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
        const { tagline, mainTitle, description, buttonText, youtubeUrl, logoUrl, isActive } = req.body;

        let heroSection = await HeroSection.findOne({});

        if (!heroSection) {
            return res.status(404).json({ message: 'Hero section not found' });
        }

        // Update fields
        heroSection.tagline = tagline || heroSection.tagline;
        heroSection.mainTitle = mainTitle || heroSection.mainTitle;
        heroSection.description = description || heroSection.description;
        heroSection.buttonText = buttonText || heroSection.buttonText;
        if (logoUrl !== undefined) heroSection.logoUrl = logoUrl;
        if (youtubeUrl !== undefined) heroSection.youtubeUrl = youtubeUrl;
        heroSection.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : heroSection.isActive);

        const heroImageFile = req.files?.image?.[0] || req.file;
        const logoImageFile = req.files?.logo?.[0];

        // Upload new hero image if provided
        if (heroImageFile) {
            const result = await uploadImageWithFallback(heroImageFile, {
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
            heroSection.logoUrl = result.secure_url;
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
