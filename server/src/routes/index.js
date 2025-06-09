const express = require('express');

const { apiV1AadhaarRoutes, 
        apiV1PANRoutes, 
        apiV1UserRoutes, 
        apiV1XMarkSheetRoutes, 
        apiV1XIIMarkSheetRoutes, 
        apiV1MovieTicketRoutes, 
        apiV1TrainTicketRoutes
    } = require('./v1/index');

const router = express.Router();

router.use('/v1', apiV1UserRoutes);
router.use('/v1', apiV1AadhaarRoutes);
router.use('/v1', apiV1PANRoutes);
router.use('/v1', apiV1XMarkSheetRoutes);
router.use('/v1', apiV1XIIMarkSheetRoutes);
router.use('/v1', apiV1MovieTicketRoutes);
router.use('/v1', apiV1TrainTicketRoutes);

module.exports = router;