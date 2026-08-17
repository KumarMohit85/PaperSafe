const express = require('express');

const { userController } = require('../../controllers/index');
const authMiddleware = require('../../middlewares/authMiddleware');

const router = express.Router();

// Public routes (no auth needed)
router.post('/register', userController.userRegistration);
router.post('/requestOTP', userController.otpRequest);
router.post('/verifyOTP', userController.otpVerification);
router.post('/refreshToken', userController.refreshToken);

// Protected routes
router.patch('/updateUser/:id', authMiddleware, userController.updateUserInfo);
router.delete('/deleteUser/:id', authMiddleware, userController.deleteUser);

module.exports = router;