const express = require('express');
const router = express.Router();
const multer = require('multer');
const { createService, getServices, deleteService, updateService, bulkDeleteServices } = require('../controllers/serviceController');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.route('/bulk-delete')
    .post(bulkDeleteServices);

router.route('/')
    .post(upload.single('image'), createService)
    .get(getServices);

router.route('/:id')
    .put(upload.single('image'), updateService)
    .delete(deleteService);

module.exports = router;
