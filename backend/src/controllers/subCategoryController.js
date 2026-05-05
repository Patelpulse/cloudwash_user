const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const SubCategory = require('../models/SubCategory');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Helper to upload to Cloudinary using stream
const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        let cld_upload_stream = cloudinary.uploader.upload_stream(
            {
                folder: "cloud_wash_sub_categories"
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

const createSubCategory = async (req, res) => {
    try {
        const { name, category, description, price, isActive, displayOrder } = req.body;
        
        let imageUrl = '';

        if (req.file) {
            // Upload image to Cloudinary if provided
            const result = await uploadFromBuffer(req.file.buffer);
            imageUrl = result.secure_url;
        }

        const subCategory = await SubCategory.create({
            name,
            category,
            description,
            price,
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
        subCategory.price = price || subCategory.price;
        subCategory.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : subCategory.isActive);
        if (displayOrder !== undefined && displayOrder !== '') {
          subCategory.displayOrder = Number.isFinite(Number(displayOrder))
              ? Number(displayOrder)
              : subCategory.displayOrder;
        }

        if (req.file) {
            try {
                const result = await uploadFromBuffer(req.file.buffer);
                subCategory.imageUrl = result.secure_url;
            } catch (cldError) {
                console.error('Cloudinary upload failed during update:', cldError);
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
