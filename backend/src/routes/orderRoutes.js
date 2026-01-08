const express = require('express');
const router = express.Router();
const {
    createOrder,
    getMyOrders,
    getOrderById,
    verifyOTP,
    updateOrderStatus,
    cancelOrder,
    getOrdersByUserId,
    getBookedSlots
} = require('../controllers/orderController');
const { protectUser } = require('../middleware/authMiddleware');

// All order routes require authentication
router.get('/slots', protectUser, getBookedSlots); // Must be before /:id to avoid conflict
router.post('/', protectUser, createOrder);
router.get('/', protectUser, getMyOrders);
router.get('/user/:userId', getOrdersByUserId); // Admin route
router.get('/:id', protectUser, getOrderById);
router.post('/verify-otp', protectUser, verifyOTP);
router.patch('/:id/status', protectUser, updateOrderStatus);
router.post('/:id/cancel', protectUser, cancelOrder);

module.exports = router;
