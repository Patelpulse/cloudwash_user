const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const AboutUs = require('../models/AboutUs');
const Stats = require('../models/Stats');

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

// --- About Us ---
const getAboutUs = async (req, res) => {
    try {
        let about = await AboutUs.findOne({});
        if (!about) {
            about = await AboutUs.create({});
        }
        res.json(about);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateAboutUs = async (req, res) => {
    try {
        const { title, subtitle, description, experienceYears, points, isActive } = req.body;
        let about = await AboutUs.findOne({});
        if (!about) return res.status(404).json({ message: 'About Us not found' });

        about.title = title || about.title;
        about.subtitle = subtitle || about.subtitle;
        about.description = description || about.description;
        about.experienceYears = experienceYears || about.experienceYears;

        // Handle points array
        if (points) {
            try {
                about.points = typeof points === 'string' ? JSON.parse(points) : points;
            } catch (e) {
                about.points = points.split(',');
            }
        }

        about.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : about.isActive);

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer);
            about.imageUrl = result.secure_url;
        }

        await about.save();
        res.json(about);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// --- Stats ---
const getStats = async (req, res) => {
    try {
        let stats = await Stats.findOne({});
        if (!stats) {
            stats = await Stats.create({});
        }
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
        if (!stats) return res.status(404).json({ message: 'Stats not found' });

        stats.happyClients = happyClients || stats.happyClients;
        stats.totalBranches = totalBranches || stats.totalBranches;
        stats.totalCities = totalCities || stats.totalCities;
        stats.totalOrders = totalOrders || stats.totalOrders;
        stats.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : stats.isActive);

        await stats.save();
        res.json(stats);
    } catch (error) {
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    getAboutUs,
    updateAboutUs,
    getStats,
    updateStats
};
