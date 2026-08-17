const jwt = require('jsonwebtoken');
const {
    JWT_SECRET,
    JWT_REFRESH_SECRET,
    JWT_EXPIRES_IN,
    JWT_REFRESH_EXPIRES_IN,
} = require('../../config/serverConfig');

/**
 * Generate access + refresh tokens for a user document.
 * @param {Object} user - Mongoose user document
 * @returns {{ accessToken: string, refreshToken: string }}
 */
function generateTokens(user) {
    const payload = {
        id: user._id.toString(),
        emailID: user.emailID,
    };

    const accessToken = jwt.sign(payload, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
    });

    const refreshToken = jwt.sign(payload, JWT_REFRESH_SECRET, {
        expiresIn: JWT_REFRESH_EXPIRES_IN,
    });

    return { accessToken, refreshToken };
}

/**
 * Verify an access token. Throws if invalid or expired.
 * @param {string} token
 * @returns {Object} decoded payload
 */
function verifyAccessToken(token) {
    return jwt.verify(token, JWT_SECRET);
}

/**
 * Verify a refresh token. Throws if invalid or expired.
 * @param {string} token
 * @returns {Object} decoded payload
 */
function verifyRefreshToken(token) {
    return jwt.verify(token, JWT_REFRESH_SECRET);
}

module.exports = { generateTokens, verifyAccessToken, verifyRefreshToken };
