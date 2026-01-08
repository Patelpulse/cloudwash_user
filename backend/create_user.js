const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./src/models/User');

// Load env vars
dotenv.config();

const createTestUser = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ Connected to MongoDB');

        const testEmail = 'admin@cloudwash.com';
        const testPassword = '123456';

        // Check if user exists
        let user = await User.findOne({ email: testEmail });

        if (user) {
            console.log('⚠️ User already exists. Updating password...');
            user.password = testPassword;
            await user.save();
            console.log('✅ Password updated to: 123456');
        } else {
            console.log('Creating new test user...');
            user = await User.create({
                name: 'Admin User',
                email: testEmail,
                phone: '+919999999999',
                password: testPassword,
                firebaseUid: 'test-admin-uid'
            });
            console.log('✅ User created successfully!');
        }

        console.log('\n=============================================');
        console.log('🎉 YOU CAN NOW LOGIN WITH:');
        console.log(`📧 Email:    ${testEmail}`);
        console.log(`🔑 Password: ${testPassword}`);
        console.log('=============================================\n');

        process.exit();
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
};

createTestUser();
