const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { uploadToCloudinary } = require('../utils/cloudinary');

// Helper to generate JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'your_fallback_secret', {
        expiresIn: '30d'
    });
};

const registerUser = async (req, res) => {
    try {
        const { firebaseUid, name, email, phone, password, profileImage } = req.body;

        // Check if user already exists
        const userExists = await User.findOne({
            $or: [{ email }, { phone }, { firebaseUid }]
        });

        if (userExists) {
            return res.status(400).json({ message: 'User already exists with this email, phone, or Firebase UID' });
        }

        let cloudinaryImageUrl = profileImage;
        if (profileImage && (profileImage.startsWith('http') || profileImage.startsWith('data:image'))) {
            cloudinaryImageUrl = await uploadToCloudinary(profileImage);
        }

        const user = await User.create({
            firebaseUid,
            name,
            email,
            phone,
            password, // Will be hashed by pre-save hook
            profileImage: cloudinaryImageUrl
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                profileImage: user.profileImage,
                token: generateToken(user._id)
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const loginUser = async (req, res) => {
    try {
        const { email, password, phone, firebaseUid } = req.body;

        let user;
        if (firebaseUid) {
            // Firebase UID login (for Google Sign-In)
            user = await User.findOne({ firebaseUid });
            if (!user) {
                return res.status(401).json({ message: 'User not found. Please complete registration.' });
            }
        } else if (email && password) {
            // Email/Password login
            user = await User.findOne({ email });
            if (!user) {
                return res.status(401).json({ message: 'Invalid email or password' });
            }
            const isMatch = await user.comparePassword(password);
            if (!isMatch) {
                return res.status(401).json({ message: 'Invalid email or password' });
            }
        } else if (phone) {
            // Phone-only login (OTP flow fallback)
            user = await User.findOne({ phone });
            if (!user) {
                return res.status(401).json({ message: 'User not found' });
            }
        } else {
            return res.status(400).json({ message: 'Please provide firebaseUid, email/password, or phone' });
        }

        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            profileImage: user.profileImage,
            token: generateToken(user._id)
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getProfile = async (req, res) => {
    try {
        // req.user is set by auth middleware (to be implemented)
        const user = await User.findById(req.user._id).select('-password');
        if (user) {
            res.json(user);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);

        if (user) {
            user.name = req.body.name || user.name;
            user.email = req.body.email || user.email;
            user.phone = req.body.phone || user.phone;

            if (req.body.profileImage && req.body.profileImage.startsWith('data:image')) {
                const cloudinaryImageUrl = await uploadToCloudinary(req.body.profileImage);
                user.profileImage = cloudinaryImageUrl;
            }

            if (req.body.password) {
                user.password = req.body.password;
            }

            const updatedUser = await user.save();

            res.json({
                _id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                phone: updatedUser.phone,
                profileImage: updatedUser.profileImage,
                token: generateToken(updatedUser._id)
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getAllUsers = async (req, res) => {
    try {
        const users = await User.find({}).select('-password').sort({ createdAt: -1 });
        res.json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getUserById = async (req, res) => {
    try {
        const user = await User.findById(req.params.id).select('-password');
        if (user) {
            res.json(user);
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (user) {
            await User.deleteOne({ _id: user._id });
            res.json({ message: 'User removed' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    registerUser,
    loginUser,
    getProfile,
    updateProfile,
    getAllUsers,
    getUserById,
    deleteUser
};
