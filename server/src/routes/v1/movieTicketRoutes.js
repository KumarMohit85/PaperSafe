const express = require('express');

const { upload, authMiddleware } = require('../../middlewares/index');
const { movieTicketController } = require('../../controllers/index');

const router = express.Router();

router.post('/uploadMovieTicket', authMiddleware, upload.single('movieTicket'), movieTicketController.uploadMovieTicket);
router.get('/downloadMovieTicket/:id', authMiddleware, movieTicketController.downloadMovieTicket);
router.delete('/deleteMovieTicket/:id', authMiddleware, movieTicketController.deleteMovieTicket);

module.exports = router;