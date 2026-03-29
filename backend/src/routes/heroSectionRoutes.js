const express = require('express');
const router = express.Router();
const multer = require('multer');
const { getHeroSection, updateHeroSection } = require('../controllers/heroSectionController');

// Configure Multer to store file in memory
const upload = multer({ storage: multer.memoryStorage() });

router.route('/')
    .get(getHeroSection)
    .put(
        upload.fields([
            { name: 'image', maxCount: 1 },
            { name: 'logo', maxCount: 1 },
        ]),
        updateHeroSection
    );

module.exports = router;
