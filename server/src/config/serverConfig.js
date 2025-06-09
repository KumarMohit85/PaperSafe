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
    EMAIL_PASSKEY: process.env.EMAIL_PASSKEY
}