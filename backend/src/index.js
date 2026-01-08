const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

// Socket.io setup
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS']
    }
});

io.on('connection', (socket) => {
    console.log('User connected to socket:', socket.id);

    // Allow client to join a room specific to their user ID
    socket.on('join', (userId) => {
        if (userId) {
            socket.join(userId);
            console.log(`Socket ${socket.id} joined room ${userId}`);
        }
    });

    socket.on('disconnect', () => {
        console.log('User disconnected from socket:', socket.id);
    });
});

// Middleware
// Enable CORS for all routes
// Enable CORS with explicit options
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Make io accessible to our routers
app.use((req, res, next) => {
    req.io = io;
    next();
});

// Request logging middleware
app.use((req, res, next) => {
    console.log(`📥 ${req.method} ${req.path}`);
    next();
});

// Import routes
const categoryRoutes = require('./routes/categoryRoutes');
const subCategoryRoutes = require('./routes/subCategoryRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const bannerRoutes = require('./routes/bannerRoutes');
const cityRoutes = require('./routes/cityRoutes');
const addonRoutes = require('./routes/addonRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const adminRoutes = require('./routes/adminRoutes');
const heroSectionRoutes = require('./routes/heroSectionRoutes');
const webContentRoutes = require('./routes/webContentRoutes');
const testimonialRoutes = require('./routes/testimonialRoutes');
const whyChooseUsRoutes = require('./routes/whyChooseUsRoutes');
const userRoutes = require('./routes/userRoutes');
const addressRoutes = require('./routes/addressRoutes');
const orderRoutes = require('./routes/orderRoutes');

// Use routes
app.use('/api/categories', categoryRoutes);
app.use('/api/sub-categories', subCategoryRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/cities', cityRoutes);
app.use('/api/addons', addonRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/hero', heroSectionRoutes);
app.use('/api/web-content', webContentRoutes);
app.use('/api/testimonials', testimonialRoutes);
app.use('/api/why-choose-us', whyChooseUsRoutes);
app.use('/api/user', userRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/orders', orderRoutes);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
