const { uploadToImageKit } = require('../utils/imagekit');
const SubCategory = require('../models/SubCategory');

const uploadFromBuffer = async (buffer, fileName) => {
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/sub_categories");
    return result;
};

const parsePrice = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
};

const createSubCategory = async (req, res) => {
    try {
        const { name, category, description, price, isActive, displayOrder } = req.body;
        const parsedPrice = parsePrice(price);
        
        let imageUrl = '';

        if (req.file) {
            // Upload image to ImageKit if provided
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            imageUrl = result.url;
        }

        if (!name || !name.toString().trim()) {
            return res.status(400).json({ message: 'SubCategory name is required' });
        }

        if (!category) {
            return res.status(400).json({ message: 'Category is required' });
        }

        if (parsedPrice === null) {
            return res.status(400).json({ message: 'Price must be a valid number' });
        }

        const subCategory = await SubCategory.create({
            name,
            category,
            description,
            price: parsedPrice,
            imageUrl,
            isActive: isActive === 'true',
            displayOrder: Number.isFinite(Number(displayOrder))
                ? Number(displayOrder)
                : 100000,
        });

        res.status(201).json(subCategory);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getSubCategories = async (req, res) => {
    try {
        const query = {};
        if (req.query.categoryId) {
            query.category = req.query.categoryId;
        }
        // Populate specific fields from the 'category' reference using just the path 'category'
        // Mongoose will look up the model 'Category' because we defined ref: 'Category' in the schema
        const subCategories = await SubCategory.find(query).populate('category', 'name');
        const sorted = subCategories.sort((a, b) => {
            const aOrder = a.displayOrder ?? 100000;
            const bOrder = b.displayOrder ?? 100000;
            if (aOrder !== bOrder) return aOrder - bOrder;
            return new Date(a.createdAt) - new Date(b.createdAt);
        });
        res.json(sorted);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteSubCategory = async (req, res) => {
    try {
        const subCategory = await SubCategory.findById(req.params.id);

        if (!subCategory) {
            return res.status(404).json({ message: 'SubCategory not found' });
        }

        await subCategory.deleteOne();
        res.json({ message: 'SubCategory removed' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

const updateSubCategory = async (req, res) => {
    try {
        const { name, category, description, price, isActive, displayOrder } = req.body;
        const subCategory = await SubCategory.findById(req.params.id);

        if (!subCategory) {
            return res.status(404).json({ message: 'SubCategory not found' });
        }

        subCategory.name = name || subCategory.name;
        if (category) subCategory.category = category;
        subCategory.description = description || subCategory.description;
        
        if (price !== undefined && price !== '') {
            const parsedPrice = parsePrice(price);
            if (parsedPrice === null) {
                return res.status(400).json({ message: 'Price must be a valid number' });
            }
            subCategory.price = parsedPrice;
        }

        subCategory.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : subCategory.isActive);
        if (displayOrder !== undefined && displayOrder !== '') {
            subCategory.displayOrder = Number.isFinite(Number(displayOrder))
                ? Number(displayOrder)
                : subCategory.displayOrder;
        }

        if (req.file) {
            try {
                const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
                subCategory.imageUrl = result.url;
            } catch (cldError) {
                console.error('ImageKit upload failed during update:', cldError);
                // Continue without updating imageUrl
            }
        }

        const updatedSubCategory = await subCategory.save();
        res.json(updatedSubCategory);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    createSubCategory,
    getSubCategories,
    deleteSubCategory,
    updateSubCategory
};
