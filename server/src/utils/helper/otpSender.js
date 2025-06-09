const nodemailer = require('nodemailer');

const { EMAIL_ID, EMAIL_PASSKEY } = require('../../config/serverConfig');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: EMAIL_ID,
    pass: EMAIL_PASSKEY
  }
});

const sendOTP = async(emailID, otp) => {
  try {

    const info = await transporter.sendMail({
      from: 'PaperSafe',
      to: emailID,
      subject: 'PaperSafe Verification Code',
      text: `Your Verification Code is ${otp}`
    });

    return true;

  } catch (error) {
    console.log('Error Occured in OTP Sending');
    throw error;
  }
} 


module.exports = sendOTP;