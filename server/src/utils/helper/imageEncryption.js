const crypto = require('crypto');
const fs = require('fs');
const { pipeline } = require('stream/promises');
const { Buffer } = require('buffer');

const { ENCRYPTION_KEY, IV } = require('../../config/serverConfig');

const encryptionKey = Buffer.from(ENCRYPTION_KEY, 'hex');
const iv = Buffer.from(IV, 'hex');

const encryptImage = async (filePath) => {
    try {
      
      const cipher = crypto.createCipheriv('aes-256-cbc', encryptionKey, iv);
      const input = fs.createReadStream(filePath);
      const output = fs.createWriteStream(`${filePath}.enc`);
  
      await pipeline(input, cipher, output);
  
      return `${filePath}.enc`;
    } catch (error) {
      throw error;
    }
  };

  module.exports = encryptImage;