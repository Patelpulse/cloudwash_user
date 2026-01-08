const Address = require('../models/Address');

const addAddress = async (req, res) => {
    try {
        const { label, name, phone, houseNumber, street, landmark, city, pincode, isDefault, latitude, longitude } = req.body;
        const userId = req.user._id;

        // If this is the first address or isDefault is true, unset other defaults
        if (isDefault) {
            await Address.updateMany({ userId }, { isDefault: false });
        } else {
            const addressCount = await Address.countDocuments({ userId });
            if (addressCount === 0) {
                req.body.isDefault = true;
            }
        }

        const address = await Address.create({
            userId,
            label,
            name,
            phone,
            houseNumber,
            street,
            landmark,
            city,
            pincode,
            isDefault: req.body.isDefault || isDefault,
            latitude,
            longitude
        });

        res.status(201).json(address);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const getMyAddresses = async (req, res) => {
    try {
        const addresses = await Address.find({ userId: req.user._id }).sort({ createdAt: -1 });
        res.json(addresses);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const updateAddress = async (req, res) => {
    try {
        const address = await Address.findById(req.params.id);

        if (!address) {
            return res.status(404).json({ message: 'Address not found' });
        }

        if (address.userId.toString() !== req.user._id.toString()) {
            return res.status(401).json({ message: 'Not authorized' });
        }

        if (req.body.isDefault) {
            await Address.updateMany({ userId: req.user._id }, { isDefault: false });
        }

        const updatedAddress = await Address.findByIdAndUpdate(
            req.params.id,
            { ...req.body },
            { new: true }
        );

        res.json(updatedAddress);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const deleteAddress = async (req, res) => {
    try {
        const address = await Address.findById(req.params.id);

        if (!address) {
            return res.status(404).json({ message: 'Address not found' });
        }

        if (address.userId.toString() !== req.user._id.toString()) {
            return res.status(401).json({ message: 'Not authorized' });
        }

        await address.deleteOne();
        res.json({ message: 'Address removed' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

const setDefaultAddress = async (req, res) => {
    try {
        const address = await Address.findById(req.params.id);

        if (!address) {
            return res.status(404).json({ message: 'Address not found' });
        }

        if (address.userId.toString() !== req.user._id.toString()) {
            return res.status(401).json({ message: 'Not authorized' });
        }

        await Address.updateMany({ userId: req.user._id }, { isDefault: false });
        address.isDefault = true;
        await address.save();

        res.json(address);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

module.exports = {
    addAddress,
    getMyAddresses,
    updateAddress,
    deleteAddress,
    setDefaultAddress
};
