const dotenv = require('dotenv');

dotenv.config();

module.exports = {
    PORT: process.env.PORT,
    MONGODB_URI: process.env.MONGODB_URI,
    CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME,
    CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY,
    CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET,
    ENCRYPTION_KEY: process.env.ENCRYPTION_KEY,
    IV: process.env.IV,
    EMAIL_ID: process.env.EMAIL_ID,
    EMAIL_PASSKEY: process.env.EMAIL_PASSKEY,
    JWT_SECRET: process.env.JWT_SECRET || 'papersafe_jwt_secret_change_in_prod',
    JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'papersafe_refresh_secret_change_in_prod',
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
    JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
}