const NodeCache = require('node-cache');

const otpCache = new NodeCache({ stdTTL: 180 });

const saveOTP = (emailID, otp) => {
  otpCache.set(emailID, otp);
};

const validateOTP = (emailID, otp) => {
  const storedOTP = otpCache.get(emailID);
  if (storedOTP && storedOTP === otp) {
    otpCache.del(emailID);
    return true;
  }
  return false;
};

module.exports = { saveOTP, validateOTP };
