const express = require('express');
const router = express.Router();
const multer = require('multer');
const { getAboutUs, updateAboutUs, getStats, updateStats } = require('../controllers/webSectionsController');

const upload = multer({ storage: multer.memoryStorage() });

router.route('/about')
    .get(getAboutUs)
    .put(upload.single('image'), updateAboutUs);

router.route('/stats')
    .get(getStats)
    // Admin currently submits stats via multipart form-data.
    // `upload.none()` parses text fields without expecting files.
    .put(upload.none(), updateStats);

module.exports = router;
