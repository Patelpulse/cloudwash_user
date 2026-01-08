const express = require('express');
const router = express.Router();
const {
    addAddress,
    getMyAddresses,
    updateAddress,
    deleteAddress,
    setDefaultAddress
} = require('../controllers/addressController');

const { protectUser } = require('../middleware/authMiddleware');

router.use(protectUser); // All address routes require authentication

router.post('/', addAddress);
router.get('/', getMyAddresses);
router.put('/:id', updateAddress);
router.delete('/:id', deleteAddress);
router.patch('/:id/default', setDefaultAddress);

module.exports = router;
