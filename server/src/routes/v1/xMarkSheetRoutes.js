const express = require('express');

const { upload, authMiddleware } = require('../../middlewares/index');
const { XMarkSheetController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadXMarkSheet', authMiddleware, upload.single('xMarkSheet'), XMarkSheetController.uploadxMarkSheet);
router.get('/downloadXMarkSheet/:id', authMiddleware, XMarkSheetController.downloadxMarkSheet);
router.delete('/deleteXMarkSheet/:id', authMiddleware, XMarkSheetController.deletexMarkSheet);

module.exports = router;