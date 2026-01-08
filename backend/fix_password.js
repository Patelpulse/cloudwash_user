const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./src/models/User');

// Load env vars
dotenv.config();

const fixUserPassword = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ Connected to MongoDB');

        const targetEmail = 'rohitsengar02@gmail.com';
        const newPassword = 'RUdra@#602';

        // Check if user exists
        let user = await User.findOne({ email: targetEmail });

        if (user) {
            console.log(`👤 User found: ${user.name} (${user.email})`);
            console.log('🔄 Updating password...');

            // This will trigger the pre-save hook to hash the password
            user.password = newPassword;
            await user.save();

            console.log('✅ Password updated successfully!');
        } else {
            console.log(`⚠️ User ${targetEmail} not found.`);
            console.log('🆕 Creating new user with this email...');

            user = await User.create({
                name: 'Rohit User', // Default name
                email: targetEmail,
                phone: '+910000000000', // Default phone
                password: newPassword,
                firebaseUid: 'manual-creation-' + Date.now()
            });
            console.log('✅ New user created successfully!');
        }

        console.log('\n=============================================');
        console.log('🎉 LOGIN NOW WORKS FOR:');
        console.log(`📧 Email:    ${targetEmail}`);
        console.log(`🔑 Password: ${newPassword}`);
        console.log('=============================================\n');

        process.exit();
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
};

fixUserPassword();
