const express = require('express');

const { upload, authMiddleware } = require('../../middlewares/index');
const { aadhaarCardController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadAadhaar', authMiddleware, upload.single('aadhaar'), aadhaarCardController.uploadAadhaar);
router.get('/downloadAadhaar/:id', authMiddleware, aadhaarCardController.downloadAadhaar);
router.get('/aadhaarDetails/:id', authMiddleware, aadhaarCardController.getAadhaarDetails);
router.delete('/deleteAadhaar/:id', authMiddleware, aadhaarCardController.deleteAadhaar);

module.exports = router;