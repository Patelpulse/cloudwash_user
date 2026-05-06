const { uploadToImageKit } = require('../utils/imagekit');
const Testimonial = require('../models/Testimonial');

const uploadFromBuffer = async (buffer, fileName) => {
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/testimonials");
    return result;
};

const getTestimonials = async (req, res) => {
    try {
        const testimonials = await Testimonial.find({});
        res.json(testimonials);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const createTestimonial = async (req, res) => {
    try {
        const { name, role, message, rating, isActive } = req.body;
        let imageUrl = '';

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            imageUrl = result.url;
        }

        const testimonial = await Testimonial.create({
            name,
            role,
            message,
            rating,
            imageUrl,
            isActive: isActive === 'true'
        });

        res.status(201).json(testimonial);
    } catch (error) {
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteTestimonial = async (req, res) => {
    try {
        await Testimonial.findByIdAndDelete(req.params.id);
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting' });
    }
};

const updateTestimonial = async (req, res) => {
    try {
        const { name, role, message, rating, isActive } = req.body;
        const testimonial = await Testimonial.findById(req.params.id);
        if (!testimonial) return res.status(404).json({ message: 'Not found' });

        testimonial.name = name || testimonial.name;
        testimonial.role = role || testimonial.role;
        testimonial.message = message || testimonial.message;
        if (rating) testimonial.rating = rating;
        if (isActive !== undefined) testimonial.isActive = isActive === 'true';

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            testimonial.imageUrl = result.url;
        }

        await testimonial.save();
        res.json(testimonial);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    getTestimonials,
    createTestimonial,
    deleteTestimonial,
    updateTestimonial
};
