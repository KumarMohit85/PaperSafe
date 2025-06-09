const crypto = require('crypto');
const fs = require('fs');
const { pipeline } = require('stream/promises');
const { Buffer } = require('buffer');

const { ENCRYPTION_KEY, IV } = require('../../config/serverConfig');

const encryptionKey = Buffer.from(ENCRYPTION_KEY, 'hex');
const iv = Buffer.from(IV, 'hex');

const decryptImage = async (filePath, outputPath) => {
    try {
      const decipher = crypto.createDecipheriv('aes-256-cbc', encryptionKey, iv);
      const input = fs.createReadStream(filePath);
      const output = fs.createWriteStream(outputPath);
  
      await pipeline(input, decipher, output);
  
      return outputPath;
    } catch (error) {
      throw new Error(`Decryption failed: ${error.message}`);
    }
  };

  module.exports = decryptImage;