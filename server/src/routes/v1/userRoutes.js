const express = require('express');

const { userController } = require('../../controllers/index');

const router = express.Router();

router.post('/register', userController.userRegistration);
router.post('/requestOTP', userController.otpRequest);
router.post('/verifyOTP', userController.otpVerification);
router.patch('/updateUser/:id', userController.updateUserInfo);
router.delete('/deleteUser/:id', userController.deleteUser);

module.exports = router;