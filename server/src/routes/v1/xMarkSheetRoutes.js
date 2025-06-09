const express = require('express');

const { upload } = require('../../middlewares/index');
const { XMarkSheetController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadXMarkSheet', upload.single('xMarkSheet'), XMarkSheetController.uploadxMarkSheet);
router.get('/downloadXMarkSheet/:id', XMarkSheetController.downloadxMarkSheet);
router.delete('/deleteXMarkSheet/:id', XMarkSheetController.deletexMarkSheet);

module.exports = router;