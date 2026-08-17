const { generateOTP, saveOTP, validateOTP, sendOTP } = require('../utils/helper/index');
const { UserRepository } = require('../repository/index');
const { uniqueIDGenerator } = require('../utils/helper/index');

class UserService{
    constructor(){
        this.userRepository = new UserRepository();
        this.uniqueIDGenerator = uniqueIDGenerator;
    }

    async registerUser(data){
        try {
            const uniqueID = uniqueIDGenerator(data.firstName, data.mobileNumber);
            data = {...data, uniqueID: uniqueID};

            const response = await this.userRepository.create(data);
            return response;

        } catch (error) {
            console.log("Error Occure in User Service Layer");
            throw error;
        }
    }

    async sendOPT(emailID){
        try {
            const otp = generateOTP();
            
            saveOTP(emailID, otp);
            
            await sendOTP(emailID, otp);
            
            const response = 'OTP Sent Successfully';

            return response;

        } catch (error) {
            console.log("Error Occur in User Service Layer");
            throw error;
        }
    }

    async verifyOTP(emailID, otp){
        try {
            if(validateOTP(emailID, otp)){

                const user = await this.getUserByEmail(emailID);
    
                if(user){
                    const { generateTokens } = require('../utils/helper/jwtHelper');
                    const { accessToken, refreshToken } = generateTokens(user);

                    return {
                        doExist: true,
                        user: user,
                        accessToken,
                        refreshToken,
                    };
    
                }else{
                    return {
                        doExist: false,
                        user: {},
                        accessToken: null,
                        refreshToken: null,
                    };
                }
    
            }else{
                throw new Error('Invalid OTP');
            }
        } catch (error) {
            console.log('Error in User Service');
            throw error;
        }
    }


    async getUserById(id){
        try {
            const response = this.userRepository.getById(id);
            return response;
        } catch (error) {
            console.log("Error in User Service Layer");
            throw error;
        }
    }

    async getUserByEmail(emailID){
        try {
            const response = this.userRepository.getByEmail(emailID);
            return response;
        } catch (error) {
            console.log("Error in User Service Layer");
            throw error;
        }
    }

    async updateUserInfo(id, data){
        try {
            const response = this.userRepository.update(id, data);
            return response;
        } catch (error) {
            console.log("Error in User Service Layer");
            throw error;
        }
    }

    async deleteUser(id){
        try {
            const response = this.userRepository.remove(id);
            return response;
        } catch (error) {
            console.log("Error in User Service Layer");
            throw error;
        }
    }

    async refreshAccessToken(refreshToken) {
        try {
            const { verifyRefreshToken, generateTokens } = require('../utils/helper/jwtHelper');
            const decoded = verifyRefreshToken(refreshToken);
            const user = await this.getUserById(decoded.id);
            if (!user) throw new Error('User not found');
            const tokens = generateTokens(user);
            return tokens;
        } catch (error) {
            console.log("Error in User Service Layer - refreshAccessToken");
            throw error;
        }
    }
}

module.exports = UserService;