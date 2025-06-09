const CrudRepository = require('./crudRepository');
const { PANCard } = require('../models/index');

class PANCardRepository extends CrudRepository{
    constructor(){
        super(PANCard);
    }

    async getByUserID(userID){
        try {
            const response = await this.model.findOne({userID});
            return response;
        } catch (error) {
            console.log("Error in PAN Repository Layer");
            throw {error};
        }
    }

    async deletePAN(userID){
        try {
            await this.model.deleteOne({
                userID: userID
            });
            return true;
        } catch (error) {
            console.log("Error in PAN Repository Layer");
            throw {error};
        }
    }
}

module.exports = PANCardRepository;