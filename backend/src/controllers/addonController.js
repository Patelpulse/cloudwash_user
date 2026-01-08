const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const Addon = require('../models/Addon');

// Configure Cloudinary (assumes env vars are loaded)
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        let cld_upload_stream = cloudinary.uploader.upload_stream(
            {
                folder: "cloud_wash_addons"
            },
            (error, result) => {
                if (result) {
                    resolve(result);
                } else {
                    reject(error);
                }
            }
        );
        streamifier.createReadStream(buffer).pipe(cld_upload_stream);
    });
};

const createAddon = async (req, res) => {
    try {
        const { name, description, price, duration, category, subCategory, isActive } = req.body;

        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image' });
        }

        const result = await uploadFromBuffer(req.file.buffer);

        const addon = await Addon.create({
            name,
            description,
            price: Number(price),
            duration,
            category,
            subCategory,
            imageUrl: result.secure_url,
            isActive: isActive === 'true'
        });

        res.status(201).json(addon);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getAddons = async (req, res) => {
    try {
        const addons = await Addon.find({})
            .populate('category', 'name')
            .populate('subCategory', 'name')
            .sort({ createdAt: -1 });
        res.json(addons);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteAddon = async (req, res) => {
    try {
        const addon = await Addon.findById(req.params.id);

        if (!addon) {
            return res.status(404).json({ message: 'Addon not found' });
        }

        await addon.deleteOne();
        res.json({ message: 'Addon removed' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateAddon = async (req, res) => {
    try {
        const { name, description, price, duration, category, subCategory, isActive } = req.body;
        const addon = await Addon.findById(req.params.id);

        if (!addon) {
            return res.status(404).json({ message: 'Addon not found' });
        }

        addon.name = name || addon.name;
        addon.description = description || addon.description;
        addon.price = price ? Number(price) : addon.price;
        addon.duration = duration || addon.duration;
        addon.category = category || addon.category;
        addon.subCategory = subCategory || addon.subCategory;

        // Handle boolean update logic properly
        if (isActive !== undefined) {
            addon.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : addon.isActive);
        }

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer);
            addon.imageUrl = result.secure_url;
        }

        const updatedAddon = await addon.save();
        res.json(updatedAddon);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    createAddon,
    getAddons,
    deleteAddon,
    updateAddon
};
