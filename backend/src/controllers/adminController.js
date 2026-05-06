const { uploadToImageKit } = require('../utils/imagekit');
const Admin = require('../models/Admin');
const firebaseAdmin = require('../config/firebase');

const uploadFromBuffer = async (buffer, fileName) => {
    const result = await uploadToImageKit(buffer, fileName, "cloudwash/admins");
    return result;
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
                email: 'admin@cloudwash.in',
                password: 'Cloudwash@2026',
                phone: '1234567890',
                location: 'New York, USA',
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
            const result = await uploadFromBuffer(req.file.buffer, req.file.originalname);
            admin.profileImage = result.url;
        }

        const updatedAdmin = await admin.save();

        // Sync with Firebase Auth if firebaseAdmin is initialized
        if (firebaseAdmin && firebaseAdmin.auth) {
            try {
                const listUsersResult = await firebaseAdmin.auth().listUsers(1000);
                const firebaseUser = listUsersResult.users.find(u => u.email === admin.email || u.uid === admin._id.toString());
                
                if (firebaseUser) {
                    await firebaseAdmin.auth().updateUser(firebaseUser.uid, {
                        email: admin.email,
                        displayName: admin.name
                    });
                    console.log('✅ Updated Firebase Auth user sync');
                }
            } catch (fbError) {
                console.warn('⚠️ Firebase Auth sync failed:', fbError.message);
            }
        }

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

        // Sync with Firebase Auth
        if (firebaseAdmin && firebaseAdmin.auth) {
            try {
                const listUsersResult = await firebaseAdmin.auth().listUsers(1000);
                const firebaseUser = listUsersResult.users.find(u => u.email === admin.email);
                
                if (firebaseUser) {
                    await firebaseAdmin.auth().updateUser(firebaseUser.uid, {
                        password: newPassword
                    });
                    console.log('✅ Updated Firebase Auth password sync');
                } else {
                    // Create if not exists to facilitate "dynamic" change
                    await firebaseAdmin.auth().createUser({
                        email: admin.email,
                        password: newPassword,
                        displayName: admin.name
                    });
                    console.log('✅ Created Firebase Auth user during password sync');
                }
            } catch (fbError) {
                console.warn('⚠️ Firebase Auth sync failed:', fbError.message);
            }
        }

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
