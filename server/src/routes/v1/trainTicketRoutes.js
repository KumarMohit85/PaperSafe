const express = require('express');

const { trainTicketController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadTrainTicket', trainTicketController.uploadTrainTicket);
router.get('/downloadTrainTicket/:id', trainTicketController.downloadTrainTicket);
router.delete('/deleteTrainTicket/:id', trainTicketController.uploadTrainTicket);

module.exports = router;