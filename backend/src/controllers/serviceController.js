const { uploadToImageKit } = require('../utils/imagekit');
const Service = require('../models/Service');

const uploadFromBuffer = async (buffer, fileName) => {
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/services");
    return result;
};

const parsePrice = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
};

const createService = async (req, res) => {
    try {
        const { name, category, subCategory: subCategoryId, price, duration, description, isActive, displayOrder } = req.body;
        const parsedPrice = parsePrice(price);
        
        let imageUrl = '';

        if (req.file) {
            // Upload image to ImageKit if provided
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            imageUrl = result.url;
        }

        if (parsedPrice === null) {
            return res.status(400).json({ message: 'Price must be a valid number' });
        }

        const service = await Service.create({
            name,
            category,
            subCategory: subCategoryId || null,
            price: parsedPrice,
            duration,
            description,
            imageUrl,
            isActive: isActive === 'true',
            displayOrder: Number.isFinite(Number(displayOrder))
                ? Number(displayOrder)
                : 100000,
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

        services.sort((a, b) => {
            const aOrder = a.displayOrder ?? 100000;
            const bOrder = b.displayOrder ?? 100000;
            if (aOrder !== bOrder) return aOrder - bOrder;
            return new Date(a.createdAt) - new Date(b.createdAt);
        });

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
        const { name, category, subCategory, price, duration, description, isActive, displayOrder } = req.body;
        const service = await Service.findById(req.params.id);

        if (!service) {
            return res.status(404).json({ message: 'Service not found' });
        }

        service.name = name || service.name;
        if (category) service.category = category;
        if (subCategory) service.subCategory = subCategory;
        
        if (price !== undefined && price !== '') {
            const parsedPrice = parsePrice(price);
            if (parsedPrice === null) {
                return res.status(400).json({ message: 'Price must be a valid number' });
            }
            service.price = parsedPrice;
        }

        service.duration = duration || service.duration;
        service.description = description || service.description;
        if (displayOrder !== undefined && displayOrder !== '') {
            const parsedOrder = Number(displayOrder);
            if (Number.isFinite(parsedOrder)) {
                service.displayOrder = parsedOrder;
            }
        }

        // Handle boolean update logic properly
        if (isActive !== undefined) {
            service.isActive = isActive === 'true' ? true : (isActive === 'false' ? false : service.isActive);
        }

        if (req.file) {
            try {
                const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
                service.imageUrl = result.url;
            } catch (cldError) {
                console.error('ImageKit upload failed during update:', cldError);
                // Continue without updating imageUrl
            }
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
