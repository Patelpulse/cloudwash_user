const express = require('express');
const router = express.Router();
const multer = require('multer');
const { createCategory, getCategories, deleteCategory, updateCategory } = require('../controllers/categoryController');

// Configure Multer to store file in memory
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024, // 10 MB
        fieldSize: 2 * 1024 * 1024, // 2 MB
    },
});

router.route('/')
    .get(getCategories)
    .post(upload.single('image'), createCategory);

router.route('/:id')
    .put(upload.single('image'), updateCategory)
    .delete(deleteCategory);

module.exports = router;
