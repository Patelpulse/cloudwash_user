const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getProfile, updateProfile, getAllUsers, getUserById, deleteUser, deleteUserProfile } = require('../controllers/userController');

const { protectUser } = require('../middleware/authMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.get('/profile', protectUser, getProfile);
router.put('/profile', protectUser, updateProfile);
router.delete('/profile', protectUser, deleteUserProfile);

router.get('/all', getAllUsers);
router.get('/:id', protectUser, getUserById); // Protect specific ID access if needed, or open for admin?
router.delete('/:id', deleteUser);

module.exports = router;
