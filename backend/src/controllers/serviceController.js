const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');
const Service = require('../models/Service');

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
                folder: "cloud_wash_services"
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

const createService = async (req, res) => {
    try {
        const { name, category, subCategory, price, duration, description, isActive } = req.body;

        if (!req.file) {
            return res.status(400).json({ message: 'Please upload an image' });
        }

        const result = await uploadFromBuffer(req.file.buffer);

        const service = await Service.create({
            name,
            category,
            subCategory, // Add this
            price,
            duration,
            description,
            imageUrl: result.secure_url,
            isActive: isActive === 'true'
        });

        res.status(201).json(service);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getServices = async (req, res) => {
    try {
        // Populate category.name for filtering/display
        const query = {};
        if (req.query.categoryId) {
            query.category = req.query.categoryId;
        }
        if (req.query.subCategoryId) {
            query.subCategory = req.query.subCategoryId;
        }

        // Populate category.name for filtering/display
        const services = await Service.find(query)
            .populate('category', 'name')
            .populate('subCategory', 'name'); // Also populate subCategory
        res.json(services);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteService = async (req, res) => {
    try {
        const service = await Service.findById(req.params.id);

        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        await service.deleteOne();
        res.json({ message: 'Service removed' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateService = async (req, res) => {
    try {
        const { name, category, subCategory, price, duration, description, isActive } = req.body;
        const service = await Service.findById(req.params.id);

        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        service.name = name || service.name;
        if (category) service.category = category;
        if (subCategory) service.subCategory = subCategory;
        service.price = price || service.price;
        service.duration = duration || service.duration;
        service.description = description || service.description;

        // Handle boolean update logic properly
        if (isActive !== undefined) {
            service.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : service.isActive);
        }

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer);
            service.imageUrl = result.secure_url;
        }

        const updatedService = await service.save();
        res.json(updatedService);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const bulkDeleteServices = async (req, res) => {
    try {
        const { ids } = req.body;
        if (!ids || !Array.isArray(ids)) {
            return res.status(400).json({ message: 'Please provide an array of service IDs' });
        }

        await Service.deleteMany({ _id: { $in: ids } });
        res.json({ message: 'Services removed successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    createService,
    getServices,
    deleteService,
    updateService,
    bulkDeleteServices
};
