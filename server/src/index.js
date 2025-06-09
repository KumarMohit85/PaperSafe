const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const { PORT } = require("./config/serverConfig");
const dbConnect = require("./config/database");
const cloudConfig = require('./config/cloudinary');
const apiRoute = require('./routes/index');

const app = express();

const setupAndStartServer = async()=>{
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({extended: true}));
    app.use(cors());

    app.use('/api', apiRoute);

    app.listen(PORT, ()=>{
        console.log(`Server Running on PORT at ${PORT}`);
        dbConnect();
        cloudConfig();
    });
}

setupAndStartServer();

