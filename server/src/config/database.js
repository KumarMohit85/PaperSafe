const mongoose = require("mongoose");
const { MONGODB_URI } = require("./serverConfig");

const dbConnect = async()=>{
    try {
        await mongoose.connect(MONGODB_URI);
        console.log("Connected to Database");
    } catch (error) {
        console.log("Error in Connecting DB");
        console.log(error);
        throw error;
    }
}

module.exports = dbConnect;