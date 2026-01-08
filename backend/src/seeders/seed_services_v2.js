const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Category = require('../models/Category');
const SubCategory = require('../models/SubCategory');
const Service = require('../models/Service');
const connectDB = require('../config/db');

// Load env vars
dotenv.config();

const serviceSamples = [
    { name: 'Standard Wash', price: 60, duration: 60, description: 'Standard quality cleaning and care.' },
    { name: 'Premium Service', price: 120, duration: 90, description: 'Extra attention to detail and premium materials.' },
    { name: 'Express Care', price: 150, duration: 45, description: 'Fastest turnaround time with high quality.' }
];

const seedServicesV2 = async () => {
    try {
        await connectDB();
        console.log('🔗 Connected to Database');

        // Clear existing services to start fresh
        await Service.deleteMany({});
        console.log('🗑️  Existing services cleared');

        const subCategories = await SubCategory.find({}).populate('category');
        console.log(`Found ${subCategories.length} sub-categories`);

        let totalAdded = 0;

        for (const subCat of subCategories) {
            console.log(`📦 Seeding services for Sub-Category: ${subCat.name} (Parent: ${subCat.category.name})`);

            for (let i = 0; i < 3; i++) {
                const sample = serviceSamples[i];
                const newService = new Service({
                    name: `${subCat.name} - ${sample.name}`,
                    description: `${sample.description} Specifically for ${subCat.name}.`,
                    price: subCat.price + sample.price, // Base subcat price + service premium
                    duration: sample.duration,
                    category: subCat.category._id,
                    subCategory: subCat._id,
                    isActive: true,
                    imageUrl: subCat.imageUrl // Reuse subcategory image or a default
                });

                await newService.save();
                totalAdded++;
            }
        }

        console.log(`\n🎉 Seeding complete! Total services added: ${totalAdded}`);
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedServicesV2();
