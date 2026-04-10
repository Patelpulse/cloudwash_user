const WhyChooseUs = require('../models/WhyChooseUs');
const admin = require('../config/firebase');

const DEFAULT_ITEMS = [
    {
        id: '000000000000000000000001',
        title: 'Premium Quality',
        description: 'We use the finest detergents and specialized care.',
        iconUrl: '',
        isActive: true,
    },
    {
        id: '000000000000000000000002',
        title: 'Express Delivery',
        description: 'Get your clothes back clean within 24 hours.',
        iconUrl: '',
        isActive: true,
    },
    {
        id: '000000000000000000000003',
        title: 'Expert Handling',
        description: 'Our staff is trained to handle delicate fabrics with care.',
        iconUrl: '',
        isActive: true,
    },
];

const DEFAULT_ITEM_ORDER = {
    '000000000000000000000001': 1,
    '000000000000000000000002': 2,
    '000000000000000000000003': 3,
};

const WHY_CHOOSE_US_META_DOC_ID = 'why_choose_us';

const parseBoolean = (value, fallback = true) => {
    if (value === undefined || value === null || value === '') return fallback;
    if (typeof value === 'boolean') return value;
    if (typeof value === 'number') return value !== 0;

    const normalized = `${value}`.trim().toLowerCase();
    if (['true', '1', 'yes', 'on'].includes(normalized)) return true;
    if (['false', '0', 'no', 'off'].includes(normalized)) return false;
    return fallback;
};

const getFirestoreCollection = () => {
    if (!admin.firestore) return null;
    return admin.firestore().collection('whyChooseUs');
};

const getMetaDoc = () => {
    if (!admin.firestore) return null;
    return admin.firestore().collection('web_landing').doc(WHY_CHOOSE_US_META_DOC_ID);
};

const hasBeenSeeded = async () => {
    const metaDoc = getMetaDoc();
    if (!metaDoc) return false;

    try {
        const snapshot = await metaDoc.get();
        return snapshot.exists && snapshot.data()?.seeded === true;
    } catch (error) {
        console.error('⚠️ Why Choose Us seed flag read failed:', error.message);
        return false;
    }
};

const markAsSeeded = async () => {
    const metaDoc = getMetaDoc();
    if (!metaDoc) return;

    try {
        await metaDoc.set(
            {
                seeded: true,
                updatedAt: new Date(),
            },
            { merge: true }
        );
    } catch (error) {
        console.error('⚠️ Why Choose Us seed flag write failed:', error.message);
    }
};

const toFirestoreDate = (value) => {
    if (!value) return new Date();
    if (value instanceof Date) return value;
    if (typeof value.toDate === 'function') return value.toDate();
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? new Date() : parsed;
};

const sortItems = (items) => {
    return items.sort((a, b) => {
        const aTime = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const bTime = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        if (aTime !== bTime) return aTime - bTime;
        const aDefaultOrder =
            DEFAULT_ITEM_ORDER[a._id.toString()] ?? Number.MAX_SAFE_INTEGER;
        const bDefaultOrder =
            DEFAULT_ITEM_ORDER[b._id.toString()] ?? Number.MAX_SAFE_INTEGER;
        if (aDefaultOrder !== bDefaultOrder) return aDefaultOrder - bDefaultOrder;
        return `${a.title || ''}`.localeCompare(`${b.title || ''}`);
    });
};

const seedDefaultItems = async () => {
    const createdItems = [];
    for (const item of DEFAULT_ITEMS) {
        const created = await WhyChooseUs.findOneAndUpdate(
            { _id: item.id },
            {
                title: item.title,
                description: item.description,
                iconUrl: item.iconUrl || '',
                isActive: item.isActive,
            },
            {
                upsert: true,
                new: true,
                runValidators: true,
                setDefaultsOnInsert: true,
            }
        );
        createdItems.push(created);
    }
    return createdItems;
};

const syncItemsToFirestore = async (items) => {
    const collection = getFirestoreCollection();
    if (!collection) return;

    try {
        const snapshot = await collection.get();
        const desiredIds = new Set(items.map((item) => item._id.toString()));
        const batch = admin.firestore().batch();
        let mutationCount = 0;

        snapshot.docs.forEach((doc) => {
            if (!desiredIds.has(doc.id)) {
                batch.delete(doc.ref);
                mutationCount += 1;
            }
        });

        items.forEach((item) => {
            const docId = item._id.toString();
            batch.set(
                collection.doc(docId),
                {
                    _id: docId,
                    mongoId: docId,
                    title: item.title,
                    description: item.description,
                    iconUrl: item.iconUrl || '',
                    isActive: item.isActive !== false,
                    createdAt: item.createdAt ? toFirestoreDate(item.createdAt) : new Date(),
                    updatedAt: item.updatedAt ? toFirestoreDate(item.updatedAt) : new Date(),
                },
                { merge: true }
            );
            mutationCount += 1;
        });

        if (mutationCount > 0) {
            await batch.commit();
        }

        if (items.length > 0) {
            await markAsSeeded();
        }
    } catch (error) {
        console.error('⚠️ Why Choose Us Firestore sync failed:', error.message);
    }
};

const getSortedItems = async () => {
    const items = await WhyChooseUs.find({}).sort({ createdAt: 1, _id: 1 });
    return sortItems(items);
};

const getItems = async (req, res) => {
    try {
        let items = await getSortedItems();
        const seeded = await hasBeenSeeded();

        if (items.length === 0 && !seeded) {
            items = await seedDefaultItems();
            items = sortItems(items);
        }

        await syncItemsToFirestore(items);
        res.json(items);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const createItem = async (req, res) => {
    try {
        const title = `${req.body.title || ''}`.trim();
        const description = `${req.body.description || ''}`.trim();
        const iconUrl = `${req.body.iconUrl || ''}`.trim();

        if (!title || !description) {
            return res.status(400).json({
                message: 'Title and description are required',
            });
        }

        const item = await WhyChooseUs.create({
            title,
            description,
            iconUrl,
            isActive: parseBoolean(req.body.isActive, true),
        });

        await syncItemsToFirestore(await getSortedItems());
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

const deleteItem = async (req, res) => {
    try {
        const item = await WhyChooseUs.findByIdAndDelete(req.params.id);
        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }

        await syncItemsToFirestore(await getSortedItems());
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting' });
    }
};

const updateItem = async (req, res) => {
    try {
        const updateData = {};

        if (req.body.title !== undefined) {
            updateData.title = `${req.body.title}`.trim();
        }
        if (req.body.description !== undefined) {
            updateData.description = `${req.body.description}`.trim();
        }
        if (req.body.iconUrl !== undefined) {
            updateData.iconUrl = `${req.body.iconUrl}`.trim();
        }
        if (req.body.isActive !== undefined) {
            updateData.isActive = parseBoolean(req.body.isActive, true);
        }

        const item = await WhyChooseUs.findByIdAndUpdate(
            req.params.id,
            updateData,
            { new: true, runValidators: true }
        );

        if (!item) {
            return res.status(404).json({ message: 'Item not found' });
        }

        await syncItemsToFirestore(await getSortedItems());
        res.json(item);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    getItems,
    createItem,
    deleteItem,
    updateItem,
};
