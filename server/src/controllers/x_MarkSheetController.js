const fs = require('fs');

const { XMarkSheetService } = require('../services/index');

const xMarkSheetService = new XMarkSheetService();

const uploadxMarkSheet = async(req, res)=>{
    try {
        const data = req.body;
        const filePath = req.file.path;

        const response = await xMarkSheetService.uploadXMarkSheet(data, filePath);
        return res.status(201).json({
            data: response,
            error:{},
            success: true,
            message: "xMarkSheet Uploaded Successfully"
        });

    } catch (error) {
        console.log("Error in xMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Upload xMarkSheet"
        });
    }
}

const downloadxMarkSheet = async(req, res)=>{
    try {
        const userID = req.params.id;

        const response = await xMarkSheetService.downloadXMarkSheet(userID);
        
        return res.status(200).sendFile(response.decryptedFilePath, (err) => {
            if(err){
                throw err;
            }
            fs.unlinkSync(response.encryptedFilePath);
            fs.unlinkSync(response.decryptedFilePath);
        });

    } catch (error) {
        console.log("Error in xMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Download xMarkSheet"
        });
    }
}

const deletexMarkSheet = async(req, res)=>{
    try {
        const userID = req.params.id;

        await xMarkSheetService.deleteXMarkSheet(userID);
        
        return res.status(200).json({
            data: {},
            error: {},
            success: true,
            message: "Successfully Deleted xMarkSheet"
        });;

    } catch (error) {
        console.log("Error in xMarkSheet Controller Layer");
        return res.status(500).json({
            data: {},
            error: {error},
            success: false,
            message: "Failed to Delete xMarkSheet"
        });
    }
}

module.exports = {
    uploadxMarkSheet,
    downloadxMarkSheet,
    deletexMarkSheet
}