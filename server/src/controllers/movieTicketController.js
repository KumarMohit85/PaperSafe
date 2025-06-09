const fs = require('fs');
const archiver = require('archiver');
const path = require('path');

const { MovieTicketService } = require('../services/index');

const movieTicketService = new MovieTicketService();

const uploadMovieTicket = async(req, res)=>{
    try {
        const data = req.body;
        const filePath = req.file.path;

        const response = await movieTicketService.uploadMovieTicket(data, filePath);
        return res.status(201).json({
            data: response,
            error:{},
            success: true,
            message: "Movie Ticket Uploaded Successfully"
        });

    } catch (error) {
        console.log("Error in Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Upload Movie Ticket"
        });
    }
}

const downloadMovieTicket = async (req, res) => {
    try {
        const userID = req.params.id;

        const responses = await movieTicketService.downloadMovieTicket(userID);
        
        const zipFilePath = path.join(__dirname, '../downloads', `${userID}-tickets.zip`);
        const output = fs.createWriteStream(zipFilePath);
        const archive = archiver('zip', { zlib: { level: 9 } });

        output.on('close', () => {
            res.download(zipFilePath, (err) => {
                if (err) {
                    throw err;
                }
                
                fs.unlinkSync(zipFilePath);
                responses.forEach(({ encryptedFilePath, decryptedFilePath }) => {
                    fs.unlinkSync(encryptedFilePath);
                    fs.unlinkSync(decryptedFilePath);
                });
            });
        });

        archive.on('error', (err) => {
            throw err;
        });

        archive.pipe(output);

        responses.forEach(({ decryptedFilePath }) => {
            archive.file(decryptedFilePath, { name: path.basename(decryptedFilePath) });
        });

        archive.finalize();

    } catch (error) {
        console.log('Error in Controller Layer', error);
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: 'Failed to download movie tickets'
        });
    }
};

const deleteMovieTicket = async(req, res)=>{
    try {
        const id = req.params.id;

        await movieTicketService.deleteMovieTicket(id);
        
        return res.status(200).json({
            data: {},
            error: {},
            success: true,
            message: "Successfully Deleted Movie Ticket"
        });;

    } catch (error) {
        console.log("Error in Controller Layer");
        return res.status(500).json({
            data: {},
            error: {error},
            success: false,
            message: "Failed to Delete Movie Ticket"
        });
    }
}

module.exports = {
    uploadMovieTicket,
    downloadMovieTicket,
    deleteMovieTicket
}