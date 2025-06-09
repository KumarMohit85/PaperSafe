const express = require('express');

const { upload } = require('../../middlewares/index');
const { panCardController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadPAN', upload.single('pan'), panCardController.uploadPAN);
router.get('/downloadPAN/:id', panCardController.downloadPAN);
router.get('panDetails/:id', panCardController.getPANDetails);
router.delete('/deletePAN/:id', panCardController.deletePANCard);

module.exports = router;