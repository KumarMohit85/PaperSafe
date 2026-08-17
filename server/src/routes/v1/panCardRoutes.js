const express = require('express');

const { upload, authMiddleware } = require('../../middlewares/index');
const { panCardController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadPAN', authMiddleware, upload.single('pan'), panCardController.uploadPAN);
router.get('/downloadPAN/:id', authMiddleware, panCardController.downloadPAN);
router.get('/panDetails/:id', authMiddleware, panCardController.getPANDetails);
router.delete('/deletePAN/:id', authMiddleware, panCardController.deletePANCard);

module.exports = router;