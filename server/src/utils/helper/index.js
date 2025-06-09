const { saveOTP, validateOTP } = require('./optStorage');
const sendOTP = require('./otpSender');

module.exports = {
    uniqueIDGenerator: require("./uniqueIDGenerator"),
    encryptImage: require("./imageEncryption"),
    decryptImage: require("./imageDecryption"),
    generateOTP: require('./otpGeneration'),
    saveOTP,
    validateOTP,
    sendOTP: sendOTP
}