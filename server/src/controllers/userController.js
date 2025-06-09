const { UserService } = require('../services/index');

const userService = new UserService();

const userRegistration = async(req, res)=>{
    try {
        const data = req.body;

        const response = await userService.registerUser(data);
        return res.status(201).json({
            data: response,
            error:{},
            success: true,
            message: "User Successfully Registered"
        });

    } catch (error) {
        console.log("Error in User Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Register User"
        });
    }
}

const otpRequest = async(req, res)=>{
    try {
        const { emailID } = req.body;

        const response = await userService.sendOPT(emailID);
        return res.status(200).json({
            data: response,
            error:{},
            success: true,
            message: "OTP Successfully Sent"
        });

    } catch (error) {
        console.log("Error in User Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Failed to Send OTP"
        });
    }
}

const otpVerification = async(req, res)=>{
    try {
        const { emailID, otp } = req.body;

        const response = await userService.verifyOTP(emailID, otp);
        return res.status(200).json({
            data: response,
            error:{},
            success: true,
            message: "Verified"
        });

    } catch (error) {
        console.log("Error in User Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Invalid OTP"
        });
    }
}

const updateUserInfo = async(req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;

        const response = await userService.updateUserInfo(id, data);
        return res.status(200).json({
            data: response,
            error:{},
            success: true,
            message: "User Info Modified"
        })
    } catch (error) {
        console.log("Error in User Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Unable to modify User Info"
        });
    }
}

const deleteUser = async(req, res) => {
    try {
        const id = req.params.id;

        const response = await userService.deleteUser(id);
        return res.status(200).json({
            data: response,
            error:{},
            success: true,
            message: "User Deleted Successfully"
        })
    } catch (error) {
        console.log("Error in User Controller Layer");
        return res.status(500).json({
            data: {},
            error: error,
            success: false,
            message: "Unable to delete User"
        });
    }
}

module.exports = {
    userRegistration,
    otpRequest,
    otpVerification,
    updateUserInfo,
    deleteUser
}