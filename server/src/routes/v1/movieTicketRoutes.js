const express = require('express');

const { upload } = require('../../middlewares/index');
const { movieTicketController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadMovieTicket', upload.single('movieTicket'), movieTicketController.uploadMovieTicket);
router.get('/downloadMovieTicket/:id', movieTicketController.downloadMovieTicket);
router.delete('/deleteMovieTicket/:id', movieTicketController.deleteMovieTicket);

module.exports = router;