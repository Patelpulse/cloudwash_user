const User = require('../models/User'); // Restart trigger
const jwt = require('jsonwebtoken');
const { uploadToImageKit } = require('../utils/imagekit');

// Helper to generate JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'your_fallback_secret', {
        expiresIn: '30d'
    });
};

const registerUser = async (req, res) => {
    console.log('📝 Register Request:', req.body);
    try {
        const { firebaseUid, name, email, phone, password, profileImage } = req.body;

        // Check if user already exists
        const userExists = await User.findOne({
            $or: [{ email }, { phone }, { firebaseUid }]
        });

        if (userExists) {
            console.log('❌ User exists:', userExists.email, userExists.phone);
            return res.status(400).json({ message: 'User already exists with this email, phone, or Firebase UID' });
        }
        // ... rest of registerUser
        let imageUrl = profileImage;
        if (profileImage && (profileImage.startsWith('http') || profileImage.startsWith('data:image'))) {
            const result = await uploadToImageKit(profileImage, `profile_${Date.now()}.png`, 'cloudwash/users');
            imageUrl = result.url;
        }

        const user = await User.create({
            firebaseUid,
            name,
            email,
            phone,
            password, // Will be hashed by pre-save hook
            profileImage: imageUrl
        });

        if (user) {
            console.log('✅ User created:', user._id);
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
        console.error('❌ Register Error:', error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const loginUser = async (req, res) => {
    console.log('🔑 Login Request:', req.body);
    try {
        // ... rest of loginUser
        const { email, password, phone, firebaseUid } = req.body;

        let user;
        if (firebaseUid) {
            user = await User.findOne({ firebaseUid });
            if (!user) {
                console.log('⚠️ Login: User not found for UID', firebaseUid);
                return res.status(401).json({ message: 'User not found. Please complete registration.' });
            }
        } else if (email && password) {
            user = await User.findOne({ email });
            if (!user) {
                console.log('⚠️ Login: User not found for email', email);
                return res.status(401).json({ message: 'Invalid email or password' });
            }
            const isMatch = await user.comparePassword(password);
            if (!isMatch) {
                console.log('⚠️ Login: Password mismatch for', email);
                return res.status(401).json({ message: 'Invalid email or password' });
            }
        } else if (phone) {
            user = await User.findOne({ phone });
            if (!user) {
                console.log('⚠️ Login: User not found for phone', phone);
                return res.status(401).json({ message: 'User not found' });
            }
        } else {
            return res.status(400).json({ message: 'Please provide firebaseUid, email/password, or phone' });
        }

        console.log('✅ Login success:', user.email);

        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            profileImage: user.profileImage,
            token: generateToken(user._id)
        });
    } catch (error) {
        console.error('❌ Login Error:', error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// ... other functions ...



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
                const result = await uploadToImageKit(req.body.profileImage, `profile_${Date.now()}.png`, 'cloudwash/users');
                user.profileImage = result.url;
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

const deleteUserProfile = async (req, res) => {
    console.log('🗑️ Delete Profile Request for User:', req.user._id);
    try {
        // User is attached by protectUser middleware
        // Use findByIdAndDelete for clarity and robustness
        const user = await User.findByIdAndDelete(req.user._id);

        if (user) {
            console.log('✅ User deleted:', user._id);
            res.json({ message: 'User profile deleted successfully' });
        } else {
            console.log('⚠️ Delete: User not found in DB');
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error('❌ Delete Error:', error);
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
    deleteUser,
    deleteUserProfile
};
