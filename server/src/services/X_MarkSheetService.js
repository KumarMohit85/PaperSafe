const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const { XMarkSheetRepository } = require('../repository/index');
const { encryptImage, decryptImage } = require('../utils/helper/index');

class XMarkSheetService{
    constructor(){
        this.xMarkSheetRepository = new XMarkSheetRepository();
    }

    async uploadXMarkSheet(data, filePath){
        try {
          
            const encryptedFilePath = await encryptImage(filePath);

            const result = await cloudinary.uploader.upload(encryptedFilePath, {
                resource_type: 'raw',
              });

            fs.unlinkSync(filePath);
            fs.unlinkSync(encryptedFilePath);

            data = {...data, version: result.version, public_id: result.public_id};
            
            const response = await this.xMarkSheetRepository.create(data);

            return response;
            
        } catch (error) {
            console.log("Error in xMarkSheet Service Layer");
            throw error;
        }
    }

    async downloadXMarkSheet(userID){
        try {

            const xMarkSheet = await this.xMarkSheetRepository.getByUserID(userID);

            const version = xMarkSheet.version;
            const public_id = xMarkSheet.public_id;
            const url = `https://res.cloudinary.com/ddhnegekc/raw/upload/v${version}/` + public_id;

            const encryptedFilePath = path.join(__dirname, '../downloads', `${public_id}.enc`);
            const decryptedFilePath = path.join(__dirname, '../downloads', `${public_id}.jpg`);
      
            const response = await axios({
              url,
              method: 'GET',
              responseType: 'stream',
            });
      
            const writer = fs.createWriteStream(encryptedFilePath);
            response.data.pipe(writer);
      
            await new Promise((resolve, reject) => {
              writer.on('finish', resolve);
              writer.on('error', reject);
            });
      
            await decryptImage(encryptedFilePath, decryptedFilePath);

            const filePaths = {
                encryptedFilePath,
                decryptedFilePath
            }

            return filePaths;

          } catch (error) {
            console.log('Error in xMarkSheet Service Layer');
            throw {error};
          }
    }

    async deleteXMarkSheet(userID){
      try {
        await this.xMarkSheetRepository.deleteXMarkSheet(userID);

        return true;
      } catch (error) {
        console.log('Error in xMarkSheet Service Layer');
        throw error;
      }
    }
    
}

module.exports = XMarkSheetService;