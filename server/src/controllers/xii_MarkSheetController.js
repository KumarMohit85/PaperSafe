const fs = require('fs');

const { XIIMarkSheetService } = require('../services/index');

const xiiMarkSheetService = new XIIMarkSheetService();

const uploadxiiMarkSheet = async(req, res)=>{
    try {
        const data = req.body;
        const filePath = req.file.path;

        const response = await xiiMarkSheetService.uploadXIIMarkSheet(data, filePath);
        return res.status(201).json({
            data: response,
            error:{},
            success: true,
            message: "xiiMarkSheet Uploaded Successfully"
        });

    } catch (error) {
        console.log("Error in xiiMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Upload xiiMarkSheet"
        });
    }
}

const downloadxiiMarkSheet = async(req, res)=>{
    try {
        const userID = req.params.id;

        const response = await xiiMarkSheetService.downloadXIIMarkSheet(userID);
        
        return res.status(200).sendFile(response.decryptedFilePath, (err) => {
            if(err){
                throw err;
            }
            fs.unlinkSync(response.encryptedFilePath);
            fs.unlinkSync(response.decryptedFilePath);
        });

    } catch (error) {
        console.log("Error in xiiMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Download xiiMarkSheet"
        });
    }
}

const deletexiiMarkSheet = async(req, res)=>{
    try {
        const userID = req.params.id;

        await xiiMarkSheetService.deleteXIIMarkSheet(userID);
        
        return res.status(200).json({
            data: {},
            error: {},
            success: true,
            message: "Successfully Deleted xiiMarkSheet"
        });;

    } catch (error) {
        console.log("Error in xiiMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: {error},
            success: false,
            message: "Failed to Delete xiiMarkSheet"
        });
    }
}

module.exports = {
    uploadxiiMarkSheet,
    downloadxiiMarkSheet,
    deletexiiMarkSheet
}