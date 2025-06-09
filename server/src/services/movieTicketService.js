const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const { MovieTicketRepository } = require('../repository/index');
const { encryptImage, decryptImage } = require('../utils/helper/index');

class MovieTicketService{
    constructor(){
        this.movieTicketRepository = new MovieTicketRepository();
    }

    async uploadMovieTicket(data, filePath){
        try {

            const encryptedFilePath = await encryptImage(filePath);
            const result = await cloudinary.uploader.upload(encryptedFilePath, {
                resource_type: 'raw',
              });

            fs.unlinkSync(filePath);
            fs.unlinkSync(encryptedFilePath);

            data = {...data, version: result.version, public_id: result.public_id};
            
            const response = await this.movieTicketRepository.create(data);

            return response;
            
        } catch (error) {
            console.log("Error in Movie Ticket Service Layer");
            throw error;
        }
    }

    async downloadMovieTicket(userID){
        try {

            const movieTickets = await this.movieTicketRepository.getByUserID(userID);
            const allTicketFilePaths = await Promise.all(movieTickets.map(async(ticket)=>{

                  const version = ticket.version;
                  const public_id = ticket.public_id;
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
            }));

            return allTicketFilePaths;

          } catch (error) {
            console.log('Error in Movie Ticket Service Layer');
            throw error;
          }
    }

    async deleteMovieTicket(id){
      try {
        await this.movieTicketRepository.remove(id);

        return true;
      } catch (error) {
        console.log('Error in Movie Ticket Service Layer');
        throw error;
      }
    }
    
}

module.exports = MovieTicketService;