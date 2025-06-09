const CrudRepository = require('./crudRepository');
const { TrainTicket } = require('../models/index');

class TrainTicketRepository extends CrudRepository{
    constructor(){
        super(TrainTicket);
    }

    async getByUserID(userID){
        try {
            const response = await this.model.find({userID});
            return response;
        } catch (error) {
            console.log("Error in Train Ticket Repository Layer");
            throw {error};
        }
    }
}

module.exports = TrainTicketRepository;