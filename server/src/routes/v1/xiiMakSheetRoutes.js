const express = require('express');

const { upload } = require('../../middlewares/index');
const { XIIMarkSheetController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadXIIMarkSheet', upload.single('xiiMarkSheet'), XIIMarkSheetController.uploadxiiMarkSheet);
router.get('/downloadXIIMarkSheet/:id', XIIMarkSheetController.downloadxiiMarkSheet);
router.delete('/deleteXIIMarkSheet/:id', XIIMarkSheetController.deletexiiMarkSheet);

module.exports = router;