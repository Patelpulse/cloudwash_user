const mongoose = require('mongoose');
const dotenv = require('dotenv');
const { uploadToImageKit } = require('../utils/imagekit');
const fs = require('fs');
const path = require('path');
const Category = require('../models/Category');
const connectDB = require('../config/db');

// Load env vars
dotenv.config();

// Icon mapping to category names
const iconMapping = {
    'laundry.png': 'Laundry',
    'dry_cleaning.png': 'Dry Cleaning',
    'shoe_cleaning.png': 'Shoe Cleaning',
    'leather_cleaning.png': 'Leather Cleaning',
    'curtain_cleaning.png': 'Curtain Cleaning',
    'carpet_cleaning.png': 'Carpet Cleaning'
};

const uploadIconsAndUpdateCategories = async () => {
    try {
        await connectDB();
        console.log('🔗 Connected to database');

        const iconsPath = path.join(__dirname, '../../..', 'cloud_user/assets/images/icons');
        console.log('📁 Icons path:', iconsPath);

        // Check if directory exists
        if (!fs.existsSync(iconsPath)) {
            console.error('❌ Icons directory not found:', iconsPath);
            process.exit(1);
        }

        const files = fs.readdirSync(iconsPath);
        console.log('📦 Found icons:', files);

        for (const file of files) {
            if (!iconMapping[file]) {
                console.log(`⏭️  Skipping ${file} - not in mapping`);
                continue;
            }

            const categoryName = iconMapping[file];
            const filePath = path.join(iconsPath, file);

            console.log(`\n📤 Uploading ${file} for category: ${categoryName}`);

            try {
                // Read file as buffer
                const fileBuffer = fs.readFileSync(filePath);

                // Upload to ImageKit
                const result = await uploadToImageKit(fileBuffer, file, 'cloudwash/categories');

                console.log(`✅ Uploaded to ImageKit: ${result.url}`);

                // Update category in database
                const category = await Category.findOneAndUpdate(
                    { name: categoryName },
                    { imageUrl: result.url },
                    { new: true }
                );

                if (category) {
                    console.log(`✅ Updated category: ${categoryName}`);
                } else {
                    console.log(`⚠️  Category not found: ${categoryName}`);
                }

            } catch (error) {
                console.error(`❌ Error processing ${file}:`, error.message);
            }
        }

        console.log('\n🎉 All icons uploaded and categories updated!');
        process.exit(0);

    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    }
};

uploadIconsAndUpdateCategories();
