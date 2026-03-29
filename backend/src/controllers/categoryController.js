const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const Category = require('../models/Category');

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

// Helper to upload to Cloudinary using stream
const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        if (!buffer) {
            reject(new Error('Missing file buffer'));
            return;
        }

        const cld_upload_stream = cloudinary.uploader.upload_stream(
            {
                folder: "cloud_wash_categories"
            },
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

const createCategory = async (req, res) => {
    try {
        const { name, description, price, isActive } = req.body;

        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image' });
        }

        // Upload image to Cloudinary, fallback to data URL if Cloudinary is unavailable.
        const result = await uploadImageWithFallback(req.file, {
            allowDataUrlFallback: true,
            fieldName: 'category image',
        });

        const category = await Category.create({
            name,
            description,
            price,
            imageUrl: result.secure_url,
            isActive: isActive === 'true' // FormData sends boolean as string
        });

        res.status(201).json(category);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: getErrorMessage(error) });
    }
};

const getCategories = async (req, res) => {
    try {
        const categories = await Category.find({});
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const deleteCategory = async (req, res) => {
    try {
        const category = await Category.findById(req.params.id);

        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }

        await category.deleteOne();
        res.json({ message: 'Category removed' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateCategory = async (req, res) => {
    try {
        const { name, description, price, isActive } = req.body;
        const category = await Category.findById(req.params.id);

        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }

        category.name = name || category.name;
        category.description = description || category.description;
        category.price = price || category.price;
        category.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : category.isActive);

        if (req.file) {
            const result = await uploadImageWithFallback(req.file, {
                allowDataUrlFallback: true,
                fieldName: 'category image',
            });
            category.imageUrl = result.secure_url;
        }

        const updatedCategory = await category.save();
        res.json(updatedCategory);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: getErrorMessage(error) });
    }
};

module.exports = {
    createCategory,
    getCategories,
    deleteCategory,
    updateCategory
};
