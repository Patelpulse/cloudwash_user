const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Addon = require('../models/Addon');
const connectDB = require('../config/db');

// Load env vars
dotenv.config();

const addonsData = [
    // Laundry Add-ons
    {
        name: 'Eco-Friendly Detergent Upgrade',
        description: 'Switch to premium organic detergents that are gentle on skin and environment.',
        price: 99,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/5591464/pexels-photo-5591464.jpeg',
        category: ['Laundry'],
        isActive: true
    },
    {
        name: 'Extra Fabric Softener',
        description: 'Additional premium softener for extra fluffiness and long-lasting freshness.',
        price: 49,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/1610557/pexels-photo-1610557.jpeg',
        category: ['Laundry'],
        isActive: true
    },
    {
        name: 'Germ-Shield Antiseptic Wash',
        description: 'Adds an extra rinse cycle with hospital-grade antiseptic solution.',
        price: 149,
        duration: '15',
        imageUrl: 'https://images.pexels.com/photos/4202325/pexels-photo-4202325.jpeg',
        category: ['Laundry'],
        isActive: true
    },
    {
        name: 'Starch / Crisp Finish',
        description: 'Professional starching for shirts and linens for a sharp, formal look.',
        price: 79,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/4791262/pexels-photo-4791262.jpeg',
        category: ['Laundry'],
        isActive: true
    },

    // Dry Cleaning Add-ons
    {
        name: 'Designer Garment Protection',
        description: 'Special handling and acid-free tissue wrapping for high-end fashion items.',
        price: 249,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/325876/pexels-photo-325876.jpeg',
        category: ['Dry Cleaning'],
        isActive: true
    },
    {
        name: 'Advanced Spot Treatment',
        description: 'Targeted removal for tough set-in stains using non-toxic chemicals.',
        price: 199,
        duration: '30',
        imageUrl: 'https://images.pexels.com/photos/5482386/pexels-photo-5482386.jpeg',
        category: ['Dry Cleaning'],
        isActive: true
    },
    {
        name: 'Moth Repellent Treatment',
        description: 'Natural lavender-based treatment to protect wool and silk from pests.',
        price: 129,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/4198305/pexels-photo-4198305.jpeg',
        category: ['Dry Cleaning'],
        isActive: true
    },
    {
        name: 'Premium Hanger & Dust Cover',
        description: 'Upgrade to non-slip padded hangers and breathable fabric dust covers.',
        price: 150,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/1486801/pexels-photo-1486801.jpeg',
        category: ['Dry Cleaning'],
        isActive: true
    },

    // Shoe Cleaning Add-ons
    {
        name: 'Hydrophobic Shield (Nano Spray)',
        description: 'Invisible water and stain repellent coating for sneakers and formal shoes.',
        price: 299,
        duration: '24h',
        imageUrl: 'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg',
        category: ['Shoe Cleaning'],
        isActive: true
    },
    {
        name: 'Inner-Sole Deep Sanitization',
        description: 'High-intensity UV treatment and internal foam cleaning to kill odors.',
        price: 199,
        duration: '20',
        imageUrl: 'https://images.pexels.com/photos/2562992/pexels-photo-2562992.jpeg',
        category: ['Shoe Cleaning'],
        isActive: true
    },
    {
        name: 'Lace Replacement (Premium)',
        description: 'Replace old laces with brand new high-quality flat or round cotton laces.',
        price: 99,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/1154504/pexels-photo-1154504.jpeg',
        category: ['Shoe Cleaning'],
        isActive: true
    },
    {
        name: 'Edge & Heel Color Touch-up',
        description: 'Precision recoloring of scuffed edges and heels for formal shoes.',
        price: 399,
        duration: '48h',
        imageUrl: 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg',
        category: ['Shoe Cleaning'],
        isActive: true
    },

    // Leather Cleaning Add-ons
    {
        name: 'Deep Conditioning Treatment',
        description: 'Rich oils and waxes applied to restore moisture and prevent leather cracking.',
        price: 599,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg',
        category: ['Leather Cleaning'],
        isActive: true
    },
    {
        name: 'Weather-Proof Wax Coating',
        description: 'Heavy duty wax layer to protect leather bags and jackets from rain.',
        price: 499,
        duration: '12h',
        imageUrl: 'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg',
        category: ['Leather Cleaning'],
        isActive: true
    },
    {
        name: 'Metal Hardware Polishing',
        description: 'Cleaning and buffing of buckles, zippers, and logos on leather items.',
        price: 299,
        duration: '15',
        imageUrl: 'https://images.pexels.com/photos/267320/pexels-photo-267320.jpeg',
        category: ['Leather Cleaning'],
        isActive: true
    },
    {
        name: 'Internal Lining Sanitization',
        description: 'Special cleaning for cloth or leather linings inside bags and jackets.',
        price: 349,
        duration: '30',
        imageUrl: 'https://images.pexels.com/photos/179909/pexels-photo-179909.jpeg',
        category: ['Leather Cleaning'],
        isActive: true
    },

    // Curtain Cleaning Add-ons
    {
        name: 'Anti-Static Dust Repellent',
        description: 'Special treatment to prevent dust from clinging to curtain fibers.',
        price: 149,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/1743227/pexels-photo-1743227.jpeg',
        category: ['Curtain Cleaning'],
        isActive: true
    },
    {
        name: 'Fire-Retardant Spray Solution',
        description: 'Professional application of clear flame-retardant coating for safety.',
        price: 399,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/7161022/pexels-photo-7161022.jpeg',
        category: ['Curtain Cleaning'],
        isActive: true
    },
    {
        name: 'Hook & Ring Replacement',
        description: 'Replacement of broken or rusted curtain hooks with heavy-duty metal ones.',
        price: 199,
        duration: '30',
        imageUrl: 'https://images.pexels.com/photos/6438753/pexels-photo-6438753.jpeg',
        category: ['Curtain Cleaning'],
        isActive: true
    },
    {
        name: 'Pleat Reset & Steaming',
        description: 'Industrial steam treatment to reset perfect pleats and remove deep wrinkles.',
        price: 249,
        duration: '60',
        imageUrl: 'https://images.pexels.com/photos/6636287/pexels-photo-6636287.jpeg',
        category: ['Curtain Cleaning'],
        isActive: true
    },

    // Carpet Cleaning Add-ons
    {
        name: 'Fiber Guard Protection',
        description: 'Extra protective layer to prevent liquid spills from soaking into the pile.',
        price: 499,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/6538940/pexels-photo-6538940.jpeg',
        category: ['Carpet Cleaning'],
        isActive: true
    },
    {
        name: 'Odor Neutralizer & Perfume',
        description: 'Eliminates pet and cooking smells, leaving a fresh mountain-breeze scent.',
        price: 299,
        duration: '0',
        imageUrl: 'https://images.pexels.com/photos/4068314/pexels-photo-4068314.jpeg',
        category: ['Carpet Cleaning'],
        isActive: true
    },
    {
        name: 'Edge Re-Binding Service',
        description: 'Repairing frayed or loose edges of your rug to prevent further damage.',
        price: 899,
        duration: '72h',
        imageUrl: 'https://images.pexels.com/photos/3773581/pexels-photo-3773581.jpeg',
        category: ['Carpet Cleaning'],
        isActive: true
    },
    {
        name: 'Mite & Allergy Extermination',
        description: 'Deep-acting thermal treatment to kill dust mites and remove dander.',
        price: 599,
        duration: '45',
        imageUrl: 'https://images.pexels.com/photos/7161022/pexels-photo-7161022.jpeg',
        category: ['Carpet Cleaning'],
        isActive: true
    }
];

const seedComprehensiveAddons = async () => {
    try {
        await connectDB();
        console.log('🔗 Connected to Database');

        // Optional: Clear existing addons
        // await Addon.deleteMany({});
        // console.log('🗑️  Existing addons cleared');

        let totalAdded = 0;

        for (const addonInfo of addonsData) {
            // Check if addon already exists by name
            const existing = await Addon.findOne({ name: addonInfo.name });

            if (existing) {
                console.log(`  - Addon "${addonInfo.name}" already exists, skipping.`);
                continue;
            }

            const newAddon = new Addon(addonInfo);
            await newAddon.save();
            totalAdded++;
            console.log(`  ✅ Added: ${addonInfo.name} for ${addonInfo.category[0]}`);
        }

        console.log(`\n🎉 Seeding complete! Total addons added: ${totalAdded}`);
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedComprehensiveAddons();
