const CrudRepository = require('./crudRepository');
const { AadhaarCard } = require('../models/index');

class AadhaarCardRepository extends CrudRepository{
    constructor(){
        super(AadhaarCard);
    }

    async getByUserID(userID){
        try {
            const response = await this.model.findOne({userID});
            return response;
        } catch (error) {
            console.log("Error in Aadhaar Repository Layer");
            throw {error};
        }
    }

    async deleteAadhaar(userID){
        try {
            await this.model.deleteOne({
                userID: userID
            });
            return true;
        } catch (error) {
            console.log("Error in Aadhaar Repository Layer");
            throw {error};
        }
    }
    
}

module.exports = AadhaarCardRepository;