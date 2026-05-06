const { uploadToImageKit } = require('../utils/imagekit');
const Addon = require('../models/Addon');

const uploadFromBuffer = async (buffer, fileName) => {
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/addons");
    return result;
};

const parsePrice = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
};

const createAddon = async (req, res) => {
    try {
        const { name, description, price, duration, category, subCategory, isActive } = req.body;
        const parsedPrice = parsePrice(price);

        if (parsedPrice === null) {
            return res.status(400).json({ message: 'Price must be a valid number' });
        }

        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image' });
        }

        const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);

        const addon = await Addon.create({
            name,
            description,
            price: parsedPrice,
            duration,
            category,
            subCategory,
            imageUrl: result.url,
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
        
        if (price !== undefined && price !== '') {
            const parsedPrice = parsePrice(price);
            if (parsedPrice === null) {
                return res.status(400).json({ message: 'Price must be a valid number' });
            }
            addon.price = parsedPrice;
        }

        addon.duration = duration || addon.duration;
        addon.category = category || addon.category;
        addon.subCategory = subCategory || addon.subCategory;

        // Handle boolean update logic properly
        if (isActive !== undefined) {
            addon.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : addon.isActive);
        }

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            addon.imageUrl = result.url;
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
