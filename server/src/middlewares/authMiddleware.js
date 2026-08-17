const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/serverConfig');

const authMiddleware = (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                data: {},
                error: 'No token provided',
                success: false,
                message: 'Unauthorized – missing Bearer token',
            });
        }

        const token = authHeader.split(' ')[1];

        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded; // { id, emailID, iat, exp }
        next();

    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                data: {},
                error: 'Token expired',
                success: false,
                message: 'Token has expired – please refresh',
            });
        }
        return res.status(401).json({
            data: {},
            error: error.message,
            success: false,
            message: 'Invalid token',
        });
    }
};

module.exports = authMiddleware;
