const express = require('express');

const { upload, authMiddleware } = require('../../middlewares/index');
const { XIIMarkSheetController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadXIIMarkSheet', authMiddleware, upload.single('xiiMarkSheet'), XIIMarkSheetController.uploadxiiMarkSheet);
router.get('/downloadXIIMarkSheet/:id', authMiddleware, XIIMarkSheetController.downloadxiiMarkSheet);
router.delete('/deleteXIIMarkSheet/:id', authMiddleware, XIIMarkSheetController.deletexiiMarkSheet);

module.exports = router;