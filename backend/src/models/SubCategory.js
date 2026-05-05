const mongoose = require('mongoose');

const subCategorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        required: true,
    },
    description: {
        type: String,
        default: '',
    },
    price: {
        type: Number,
        required: true,
    },
    isActive: {
        type: Boolean,
        default: true,
    },
    imageUrl: {
        type: String,
        required: false,
        default: ''
    },
    displayOrder: {
        type: Number,
        default: 100000,
        index: true,
    },
}, {
    timestamps: true,
});

module.exports = mongoose.model('SubCategory', subCategorySchema);
