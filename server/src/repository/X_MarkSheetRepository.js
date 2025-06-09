const CrudRepository = require('./crudRepository');
const { XMarkSheet } = require('../models/index');

class XMarkSheetRepository extends CrudRepository{
    constructor(){
        super(XMarkSheet);
    }

    async getByUserID(userID){
        try {
            const response = await this.model.findOne({userID});
            return response;
        } catch (error) {
            console.log("Error in XMarkSheet Repository Layer");
            throw {error};
        }
    }

    async deleteXMarkSheet(userID){
        try {
            await this.model.deleteOne({
                userID: userID
            });
            return true;
        } catch (error) {
            console.log("Error in XMarkSheet Repository Layer");
            throw {error};
        }
    }
}

module.exports = XMarkSheetRepository;