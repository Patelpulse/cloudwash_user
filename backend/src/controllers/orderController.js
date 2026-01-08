const Order = require('../models/Order');
const { sendNotification } = require('./notificationController');
const admin = require('../config/firebase');

// Helper: Generate 5-digit OTP
const generateOTP = () => {
    return Math.floor(10000 + Math.random() * 90000).toString();
};

// Helper: Sync order to Firebase
const syncOrderToFirebase = async (order) => {
    try {
        // Check if admin.firestore is available
        if (!admin.firestore) {
            console.log('⚠️ Firebase Firestore not available, skipping sync');
            return;
        }

        // Check if user has firebaseUid
        if (!order.firebaseUid) {
            console.log('⚠️ Order has no firebaseUid, skipping Firebase sync');
            return;
        }

        // Convert Mongoose document to plain object to avoid serialization issues
        const plainOrder = order.toObject();

        // Serialize services with ObjectId conversion
        const serializedServices = (plainOrder.services || []).map(service => ({
            serviceId: service.serviceId ? service.serviceId.toString() : null,
            name: service.name,
            categoryName: service.categoryName,
            subCategoryName: service.subCategoryName,
            price: service.price,
            quantity: service.quantity,
            total: service.total
        }));

        // Serialize addons with ObjectId conversion
        const serializedAddons = (plainOrder.addons || []).map(addon => ({
            addonId: addon.addonId ? addon.addonId.toString() : null,
            name: addon.name,
            price: addon.price
        }));

        const orderData = {
            orderId: plainOrder._id.toString(),
            orderNumber: plainOrder.orderNumber,
            otp: plainOrder.otp,
            user: {
                name: plainOrder.user.name,
                email: plainOrder.user.email,
                phone: plainOrder.user.phone
            },
            address: plainOrder.address || {},
            services: serializedServices,
            addons: serializedAddons,
            priceSummary: plainOrder.priceSummary || {},
            paymentMethod: plainOrder.paymentMethod,
            paymentStatus: plainOrder.paymentStatus,
            status: plainOrder.status,
            scheduledDate: plainOrder.scheduledDate ? plainOrder.scheduledDate.toISOString() : null,
            completedAt: plainOrder.completedAt ? plainOrder.completedAt.toISOString() : null,
            cancelledAt: plainOrder.cancelledAt ? plainOrder.cancelledAt.toISOString() : null,
            cancellationReason: plainOrder.cancellationReason || null,
            notes: plainOrder.notes || null,
            createdAt: plainOrder.createdAt.toISOString(),
            updatedAt: plainOrder.updatedAt.toISOString()
        };

        await admin.firestore()
            .collection('orders')
            .doc(order._id.toString())
            .set(orderData, { merge: true });

        // Also add to user's orders subcollection for easy querying
        await admin.firestore()
            .collection('users')
            .doc(order.firebaseUid)
            .collection('orders')
            .doc(order._id.toString())
            .set(orderData, { merge: true });

        console.log(`✅ Order ${order.orderNumber} synced to Firebase`);
    } catch (error) {
        console.error('❌ Firebase sync error:', error.message);
        // Don't throw - MongoDB save should succeed even if Firebase fails
    }
};

// Create new order
const createOrder = async (req, res) => {
    try {
        console.log('📦 Creating order...');
        console.log('👤 User:', {
            id: req.user?._id,
            name: req.user?.name,
            email: req.user?.email,
            firebaseUid: req.user?.firebaseUid
        });

        const {
            address,
            services,
            addons,
            priceSummary,
            paymentMethod,
            scheduledDate,
            notes
        } = req.body;

        console.log('📋 Request body:', {
            hasAddress: !!address,
            servicesCount: services?.length || 0,
            addonsCount: addons?.length || 0,
            hasPriceSummary: !!priceSummary,
            paymentMethod
        });

        const user = req.user;

        if (!user) {
            console.error('❌ No user found in request');
            return res.status(401).json({
                success: false,
                message: 'User not authenticated'
            });
        }

        // Validate required user fields
        if (!user.name || !user.email) {
            console.error('❌ User missing required fields:', { name: user.name, email: user.email });
            return res.status(400).json({
                success: false,
                message: 'User profile incomplete. Please update your profile.'
            });
        }

        // Validate required order fields
        if (!address) {
            console.error('❌ Address is required');
            return res.status(400).json({
                success: false,
                message: 'Delivery address is required'
            });
        }

        if (!services || services.length === 0) {
            console.error('❌ Services are required');
            return res.status(400).json({
                success: false,
                message: 'At least one service is required'
            });
        }

        if (!priceSummary || !priceSummary.total) {
            console.error('❌ Price summary is required');
            return res.status(400).json({
                success: false,
                message: 'Price summary is required'
            });
        }

        const otp = generateOTP();

        // Generate order number
        const timestamp = Date.now().toString().slice(-6);
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        const orderNumber = `CW${timestamp}${random}`;

        const orderData = {
            userId: user._id,
            firebaseUid: user.firebaseUid || null,
            orderNumber, // Add generated order number
            otp,
            user: {
                name: user.name,
                email: user.email,
                phone: user.phone || ''
            },
            address,
            services,
            addons: addons || [],
            priceSummary,
            paymentMethod: paymentMethod || 'Cash',
            scheduledDate,
            notes
        };

        console.log('💾 Creating order with data:', JSON.stringify(orderData, null, 2));

        const order = new Order(orderData);
        await order.save();

        console.log('✅ Order created:', order.orderNumber);

        // Sync to Firebase for real-time updates
        await syncOrderToFirebase(order);

        // Send notification to user
        await sendNotification(
            req,
            order.userId,
            'Booking Confirmed',
            `Your booking #${order.orderNumber} has been placed successfully.`,
            'order_created',
            order._id
        );

        // Emit socket event
        if (req.io) {
            req.io.emit('new_order', {
                message: `New Booking #${order.orderNumber}`,
                orderId: order._id,
                orderNumber: order.orderNumber,
                amount: order.priceSummary.total,
                customerName: user.name,
                order: order, // Send full order object
                services: order.services,
                address: order.address,
                createdAt: order.createdAt
            });
        }

        res.status(201).json({
            success: true,
            order,
            message: `Order created successfully. Your OTP is: ${otp}`
        });
    } catch (error) {
        console.error('❌ Create Order Error:', error);
        console.error('❌ Error stack:', error.stack);
        res.status(500).json({
            success: false,
            message: 'Failed to create order',
            error: error.message
        });
    }
};

// Get user's orders
const getMyOrders = async (req, res) => {
    try {
        const orders = await Order.find({ userId: req.user._id })
            .sort({ createdAt: -1 })
            .lean();

        res.json({
            success: true,
            orders
        });
    } catch (error) {
        console.error('Get Orders Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch orders',
            error: error.message
        });
    }
};

// Get order by ID
const getOrderById = async (req, res) => {
    try {
        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (order.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to view this order'
            });
        }

        res.json({
            success: true,
            order
        });
    } catch (error) {
        console.error('Get Order Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch order',
            error: error.message
        });
    }
};

// Verify OTP
const verifyOTP = async (req, res) => {
    try {
        const { orderId, otp } = req.body;

        const order = await Order.findById(orderId);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (order.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized'
            });
        }

        if (order.otp !== otp) {
            return res.status(400).json({
                success: false,
                message: 'Invalid OTP'
            });
        }

        // Update order status to confirmed
        order.status = 'confirmed';
        await order.save();

        // Sync to Firebase
        await syncOrderToFirebase(order);

        res.json({
            success: true,
            message: 'OTP verified successfully',
            order
        });
    } catch (error) {
        console.error('Verify OTP Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to verify OTP',
            error: error.message
        });
    }
};

// Update order status
const updateOrderStatus = async (req, res) => {
    try {
        const { status, cancellationReason } = req.body;

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (order.userId.toString() !== req.user._id.toString() && req.user.role !== 'admin' && req.user.role !== 'Super Administrator') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized'
            });
        }

        order.status = status;

        if (status === 'completed') {
            order.completedAt = new Date();
        } else if (status === 'cancelled') {
            order.cancelledAt = new Date();
            order.cancellationReason = cancellationReason;
        }

        await order.save();

        // Sync to Firebase
        await syncOrderToFirebase(order);

        // Notify User
        await sendNotification(
            req,
            order.userId,
            'Order Status Updated',
            `Your order #${order.orderNumber || order._id} is now ${status}.`,
            'order_update',
            order._id
        );

        res.json({
            success: true,
            message: 'Order status updated',
            order
        });
    } catch (error) {
        console.error('Update Status Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update order status',
            error: error.message
        });
    }
};

// Cancel order
const cancelOrder = async (req, res) => {
    try {
        const { cancellationReason } = req.body;

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        if (order.userId.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized'
            });
        }

        if (order.status === 'completed' || order.status === 'cancelled') {
            return res.status(400).json({
                success: false,
                message: `Cannot cancel ${order.status} order`
            });
        }

        order.status = 'cancelled';
        order.cancelledAt = new Date();
        order.cancellationReason = cancellationReason;

        await order.save();

        // Sync to Firebase
        await syncOrderToFirebase(order);

        // Notify User
        await sendNotification(
            req,
            order.userId,
            'Order Cancelled',
            `Your order #${order.orderNumber || order._id} has been cancelled.`,
            'order_update',
            order._id
        );

        res.json({
            success: true,
            message: 'Order cancelled successfully',
            order
        });
    } catch (error) {
        console.error('Cancel Order Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to cancel order',
            error: error.message
        });
    }
};

// Get orders by specific user ID (Admin)
const getOrdersByUserId = async (req, res) => {
    try {
        const orders = await Order.find({ userId: req.params.userId })
            .sort({ createdAt: -1 })
            .lean();

        res.json({
            success: true,
            orders
        });
    } catch (error) {
        console.error('Get User Orders Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch user orders',
            error: error.message
        });
    }
};

// Get booked slots for a date
const getBookedSlots = async (req, res) => {
    try {
        const { date } = req.query;

        if (!date) {
            return res.status(400).json({
                success: false,
                message: 'Date is required'
            });
        }

        const queryDate = new Date(date);
        const startOfDay = new Date(queryDate.setHours(0, 0, 0, 0));
        const endOfDay = new Date(queryDate.setHours(23, 59, 59, 999));

        const orders = await Order.find({
            scheduledDate: {
                $gte: startOfDay,
                $lte: endOfDay
            },
            status: { $ne: 'cancelled' }
        }).select('scheduledDate status');

        const slots = orders.map(order => ({
            time: order.scheduledDate,
            status: order.status
        }));

        res.json({
            success: true,
            slots
        });
    } catch (error) {
        console.error('Get Slots Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch slots',
            error: error.message
        });
    }
};

module.exports = {
    createOrder,
    getMyOrders,
    getOrderById,
    verifyOTP,
    updateOrderStatus,
    cancelOrder,
    getOrdersByUserId,
    getBookedSlots
};
