const CrudRepository = require('./crudRepository');
const { XIIMarkSheet } = require('../models/index');

class XIIMarkSheetRepository extends CrudRepository{
    constructor(){
        super(XIIMarkSheet);
    }

    async getByUserID(userID){
        try {
            const response = await this.model.findOne({userID});
            return response;
        } catch (error) {
            console.log("Error in XIIMarkSheet Repository Layer");
            throw {error};
        }
    }

    async deleteXIIMarkSheet(userID){
        try {
            await this.model.deleteOne({
                userID: userID
            });
            return true;
        } catch (error) {
            console.log("Error in XIIMarkSheet Repository Layer");
            throw {error};
        }
    }
}

module.exports = XIIMarkSheetRepository;