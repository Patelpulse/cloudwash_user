const Admin = require('../models/Admin');
const cloudinary = require('cloudinary').v2;
const streamifier = require('streamifier');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Helper to upload to Cloudinary
const uploadFromBuffer = (buffer) => {
    return new Promise((resolve, reject) => {
        const cld_upload_stream = cloudinary.uploader.upload_stream(
            {
                folder: "cloud_wash_admins"
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

const getProfile = async (req, res) => {
    try {
        // For simplicity in this admin panel, we'll fetch the first admin found
        // In a real app with auth, you'd get the ID from the token (req.user._id)
        let admin = await Admin.findOne();

        if (!admin) {
            // Seed a default admin if none exists
            admin = await Admin.create({
                name: 'Master Admin',
                email: 'admin@cloudwash.com',
                phone: '+91 98765 43210',
                location: 'New York, USA',
                password: 'password123', // In production, hash this!
                role: 'Super Administrator'
            });
        }

        res.json(admin);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateProfile = async (req, res) => {
    try {
        // Update the first admin found or by ID if provided
        const id = req.params.id;
        let admin;

        if (id && id !== 'undefined') {
            admin = await Admin.findById(id);
        } else {
            admin = await Admin.findOne();
        }

        if (!admin) {
            return res.status(404).json({ message: 'Admin not found' });
        }

        const { name, email, phone, location } = req.body;

        admin.name = name || admin.name;
        admin.email = email || admin.email;
        admin.phone = phone || admin.phone;
        admin.location = location || admin.location;

        if (req.file) {
            const result = await uploadFromBuffer(req.file.buffer);
            admin.profileImage = result.secure_url;
        }

        const updatedAdmin = await admin.save();
        res.json(updatedAdmin);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updatePassword = async (req, res) => {
    try {
        const id = req.params.id;
        let admin;

        if (id && id !== 'undefined') {
            admin = await Admin.findById(id);
        } else {
            admin = await Admin.findOne();
        }

        if (!admin) {
            return res.status(404).json({ message: 'Admin not found' });
        }

        const { currentPassword, newPassword } = req.body;

        // Simple comparison (Use bcrypt.compare in production)
        if (admin.password !== currentPassword) {
            return res.status(400).json({ message: 'Invalid current password' });
        }

        // Simple assignment (Use bcrypt.hash in production)
        admin.password = newPassword;
        await admin.save();

        res.json({ message: 'Password updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const admin = await Admin.findOne({ email });

        if (!admin) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Simple comparison (Use bcrypt.compare in production)
        if (admin.password !== password) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const jwt = require('jsonwebtoken');

        const generateToken = (id) => {
            return jwt.sign({ id }, process.env.JWT_SECRET || 'your_fallback_secret', {
                expiresIn: '30d',
            });
        };

        // ...

        // Inside login function
        res.json({
            _id: admin._id,
            name: admin.name,
            email: admin.email,
            profileImage: admin.profileImage,
            role: admin.role,
            token: generateToken(admin._id),
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    getProfile,
    updateProfile,
    updatePassword,
    login
};
