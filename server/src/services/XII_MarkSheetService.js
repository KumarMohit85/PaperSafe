const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const { XIIMarkSheetRepository } = require('../repository/index');
const { encryptImage, decryptImage } = require('../utils/helper/index');

class XIIMarkSheetService{
    constructor(){
        this.xiiMarkSheetRepository = new XIIMarkSheetRepository();
    }

    async uploadXIIMarkSheet(data, filePath){
        try {
          
            const encryptedFilePath = await encryptImage(filePath);

            const result = await cloudinary.uploader.upload(encryptedFilePath, {
                resource_type: 'raw',
              });

            fs.unlinkSync(filePath);
            fs.unlinkSync(encryptedFilePath);

            data = {...data, version: result.version, public_id: result.public_id};
            
            const response = await this.xiiMarkSheetRepository.create(data);

            return response;
            
        } catch (error) {
            console.log("Error in xiiMarkSheet Service Layer");
            throw error;
        }
    }

    async downloadXIIMarkSheet(userID){
        try {

            const xiiMarkSheet = await this.xiiMarkSheetRepository.getByUserID(userID);

            const version = xiiMarkSheet.version;
            const public_id = xiiMarkSheet.public_id;
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
            console.log('Error in xiiMarkSheet Service Layer');
            throw {error};
          }
    }

    async deleteXIIMarkSheet(userID){
      try {
        await this.xiiMarkSheetRepository.deleteXIIMarkSheet(userID);

        return true;
      } catch (error) {
        console.log('Error in xiiMarkSheet Service Layer');
        throw error;
      }
    }
    
}

module.exports = XIIMarkSheetService;