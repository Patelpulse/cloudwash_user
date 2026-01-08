const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Category = require('../models/Category');
const Service = require('../models/Service');
const connectDB = require('../config/db');

// Load env vars
dotenv.config();

const categoriesData = [
    {
        name: 'Laundry',
        services: [
            { name: 'Eco-Friendly Standard (Wash & Fold)', price: 399, duration: 24, description: 'Eco-friendly detergent wash, professional drying and crisp folding for up to 5kg.', imageUrl: 'https://images.pexels.com/photos/5591464/pexels-photo-5591464.jpeg' },
            { name: 'Silk & Delicate Specialized Wash', price: 599, duration: 48, description: 'Gentle hand-wash imitation for silk, lace, and other delicate fabrics.', imageUrl: 'https://images.pexels.com/photos/2254060/pexels-photo-2254060.jpeg' },
            { name: 'Same Day Express Laundry', price: 799, duration: 8, description: 'Priority processing for your urgent laundry needs. Delivery within 8 hours.', imageUrl: 'https://images.pexels.com/photos/4791262/pexels-photo-4791262.jpeg' }
        ]
    },
    {
        name: 'Dry Cleaning',
        services: [
            { name: 'Designer Wear Dry Clean', price: 899, duration: 72, description: 'Chemical-free cleaning for high-end designer brands and complex outfits.', imageUrl: 'https://images.pexels.com/photos/325876/pexels-photo-325876.jpeg' },
            { name: 'Wedding Lehanga / Groom Suit', price: 1499, duration: 120, description: 'Specialized deep cleaning and storage-ready packaging for wedding attire.', imageUrl: 'https://images.pexels.com/photos/1345082/pexels-photo-1345082.jpeg' },
            { name: 'Winter Essential Jacket Deep Clean', price: 449, duration: 48, description: 'Heavy-duty cleaning for padded, leather-trimmed or down-filled winter jackets.', imageUrl: 'https://images.pexels.com/photos/6311650/pexels-photo-6311650.jpeg' }
        ]
    },
    {
        name: 'Shoe Cleaning',
        services: [
            { name: 'Premium Sneaker Restoration', price: 599, duration: 48, description: 'Detailed cleaning for soles, laces, and uppers with suede/leather protection.', imageUrl: 'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg' },
            { name: 'Luxury Leather Shoe Spa', price: 499, duration: 36, description: 'Deep cleaning, conditioning, and high-gloss buffing for formal leather shoes.', imageUrl: 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg' },
            { name: 'Antibacterial Deodorizing Treatment', price: 299, duration: 12, description: 'UV treatment and specialized odor neutralizers to keep shoes fresh.', imageUrl: 'https://images.pexels.com/photos/2562992/pexels-photo-2562992.jpeg' }
        ]
    },
    {
        name: 'Leather Cleaning',
        services: [
            { name: 'Genuine Leather Jacket Conditioning', price: 1499, duration: 96, description: 'Moisturizing and sealing treatment to prevent cracking and restore luster.', imageUrl: 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg' },
            { name: 'High-End Leather Bag Cleaning', price: 1199, duration: 72, description: 'Internal and external cleaning for leather handbags from luxury brands.', imageUrl: 'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg' },
            { name: 'Leather Footwear Polish & Clean', price: 399, duration: 24, description: 'Professional buffing and cleaning for everyday leather boots/lowers.', imageUrl: 'https://images.pexels.com/photos/267320/pexels-photo-267320.jpeg' }
        ]
    },
    {
        name: 'Curtain Cleaning',
        services: [
            { name: 'Sheer Curtain Steam Clean', price: 249, duration: 48, description: 'In-house or plant-based steam treatment for thin, delicate sheer curtains.', imageUrl: 'https://images.pexels.com/photos/1743227/pexels-photo-1743227.jpeg' },
            { name: 'Heavy Velvet Drapes Treatment', price: 499, duration: 72, description: 'Deep extraction and dust removal for heavy materials like velvet and wool.', imageUrl: 'https://images.pexels.com/photos/6438753/pexels-photo-6438753.jpeg' },
            { name: 'Odor Removal & Sanitization', price: 199, duration: 24, description: 'Ozone treatment to remove smoke, pet odors, and allergens from window treatments.', imageUrl: 'https://images.pexels.com/photos/7161022/pexels-photo-7161022.jpeg' }
        ]
    },
    {
        name: 'Carpet Cleaning',
        services: [
            { name: 'Wall-to-Wall High Traffic Shampooing', price: 1999, duration: 72, description: 'Deep industrial shampooing for fixed carpets in halls and living rooms.', imageUrl: 'https://images.pexels.com/photos/6538940/pexels-photo-6538940.jpeg' },
            { name: 'Persian/Oriental Rug Specialist Care', price: 2499, duration: 120, description: 'Traditional-method cleaning for hand-knotted and antique rugs.', imageUrl: 'https://images.pexels.com/photos/3773581/pexels-photo-3773581.jpeg' },
            { name: 'Stain & Pet Odor Removal', price: 999, duration: 48, description: 'Targeted enzyme treatment for tough stains and persistent pet smells.', imageUrl: 'https://images.pexels.com/photos/4068314/pexels-photo-4068314.jpeg' }
        ]
    }
];

const seedComprehensiveServices = async () => {
    try {
        await connectDB();
        console.log('🔗 Connected to Database');

        // Optional: Clear existing services to avoid duplicates during seeding
        // await Service.deleteMany({});
        // console.log('🗑️  Existing services cleared');

        let totalAdded = 0;

        for (const catData of categoriesData) {
            // Find the category by name
            const category = await Category.findOne({ name: catData.name });

            if (!category) {
                console.warn(`⚠️ Category "${catData.name}" not found in database. Skipping...`);
                continue;
            }

            console.log(`📦 Seeding services for: ${category.name}`);

            for (const serviceInfo of catData.services) {
                // Check if service already exists for this category to avoid duplicates
                const existing = await Service.findOne({
                    name: serviceInfo.name,
                    category: category._id
                });

                if (existing) {
                    console.log(`  - Service "${serviceInfo.name}" already exists, skipping.`);
                    continue;
                }

                const newService = new Service({
                    ...serviceInfo,
                    category: category._id,
                    isActive: true
                });

                await newService.save();
                totalAdded++;
                console.log(`  ✅ Added: ${serviceInfo.name}`);
            }
        }

        console.log(`\n🎉 Seeding complete! Total services added: ${totalAdded}`);
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedComprehensiveServices();
