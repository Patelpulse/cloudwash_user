const { uploadToImageKit } = require('../utils/imagekit');
const Category = require('../models/Category');

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

const parseCategoryPrice = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
};

const parseBooleanString = (value, fallback) => {
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return fallback;
};

const parseDisplayOrder = (value, fallback = 100000) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
};

// Helper to upload to ImageKit using buffer
const uploadFromBuffer = async (buffer, fileName) => {
    if (!buffer) {
        throw new Error('Missing file buffer');
    }
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/categories");
    return result;
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
        return await uploadFromBuffer(file.buffer, file.originalname);
    } catch (error) {
        if (!allowDataUrlFallback) {
            throw error;
        }

        const errorMessage = getErrorMessage(error);
        console.warn(
            `⚠️ ImageKit upload failed for ${fieldName}. Using data URL fallback: ${errorMessage}`
        );
        return { url: toDataUrlFromFile(file) };
    }
};

const resolveCategoryImageUrl = async (
    file,
    { fieldName = 'image' } = {}
) => {
    if (!file) return '';

    try {
        const result = await uploadImageWithFallback(file, {
            allowDataUrlFallback: true,
            fieldName,
        });
        const url = result?.url?.toString().trim();
        if (url) return url;
    } catch (error) {
        const errorMessage = getErrorMessage(error);
        console.warn(
            `⚠️ Upload failed for ${fieldName}. Falling back to inline data URL: ${errorMessage}`
        );
    }

    return toDataUrlFromFile(file);
};

const createCategory = async (req, res) => {
    try {
        const { name, description, price, isActive, displayOrder } = req.body;
        const parsedPrice = parseCategoryPrice(price);
        const parsedOrder = parseDisplayOrder(displayOrder);

        if (!name || !name.toString().trim()) {
            return res.status(400).json({ message: 'Category name is required' });
        }

        if (!description || !description.toString().trim()) {
            return res.status(400).json({ message: 'Category description is required' });
        }

        if (parsedPrice === null) {
            return res.status(400).json({ message: 'Price must be a valid number' });
        }

        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image' });
        }

        const imageUrl = await resolveCategoryImageUrl(req.file, {
            fieldName: 'category image',
        });

        const category = await Category.create({
            name: name.toString().trim(),
            description: description.toString().trim(),
            price: parsedPrice,
            imageUrl,
            isActive: parseBooleanString(isActive, true),
            displayOrder: parsedOrder,
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
        const sorted = categories.sort((a, b) => {
            const aOrder = a.displayOrder ?? 100000;
            const bOrder = b.displayOrder ?? 100000;
            if (aOrder !== bOrder) return aOrder - bOrder;
            return new Date(a.createdAt) - new Date(b.createdAt);
        });
        res.json(sorted);
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
        const { name, description, price, isActive, displayOrder } = req.body;
        const category = await Category.findById(req.params.id);

        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }

        if (name !== undefined && name.toString().trim()) {
            category.name = name.toString().trim();
        }

        if (description !== undefined && description.toString().trim()) {
            category.description = description.toString().trim();
        }

        if (price !== undefined && price !== '') {
            const parsedPrice = parseCategoryPrice(price);
            if (parsedPrice === null) {
                return res.status(400).json({ message: 'Price must be a valid number' });
            }
            category.price = parsedPrice;
        }

        category.isActive = parseBooleanString(isActive, category.isActive);
        if (displayOrder !== undefined && displayOrder !== '') {
            category.displayOrder = parseDisplayOrder(displayOrder, category.displayOrder);
        }

        if (req.file) {
            category.imageUrl = await resolveCategoryImageUrl(req.file, {
                fieldName: 'category image',
            });
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
