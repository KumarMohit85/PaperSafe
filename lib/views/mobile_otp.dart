import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/views/login_signup.dart';
import 'package:_first_one/views/tell_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';

class OtpVerification extends StatefulWidget {
  OtpVerification({super.key, required this.emailID});
  String emailID;
  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  ApiService _apiService = ApiService();
  String otp = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 0),
          color: Colors.white,
          child: Column(
            children: [
              SvgPicture.asset(
                "assets/images/login_svg.svg",
                height: 270.h,
              ),
              SizedBox(
                height: 20.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OTPTextField(
                  //   length: 6,
                  //   width: 340.w,
                  //   textFieldAlignment: MainAxisAlignment.spaceBetween,
                  //   fieldWidth: 45.w,
                  //   fieldStyle: FieldStyle.box,
                  //   outlineBorderRadius: 15.r,
                  //   style: TextStyle(fontSize: 18.sp),
                  //   onCompleted: (value) {
                  //
                  //   },
                  // ),
                  // OtpTextField(
                  //   keyboardType: TextInputType.number,
                  //   numberOfFields: 6,
                  //   borderColor: Colors.black,
                  //   fieldWidth: 50,
                  //   borderRadius: BorderRadius.circular(0.r),
                  //   showFieldAsBox: true,
                  //   //runs when a code is typed in
                  //   onCodeChanged: (String code) {
                  //     //handle validation or checks here
                  //   },
                  //   //runs when every textfield is filled
                  //   onSubmit: (String verificationCode) {
                  //     setState(() {
                  //       otp = verificationCode;
                  //     });
                  //   }, // end onSubmit
                  // ),
                  Pinput(
                    length: 6,
                    keyboardType: TextInputType.number,
                    defaultPinTheme: PinTheme(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200]),
                        width: 50.w,
                        height: 45.h,
                        textStyle: TextStyle(fontSize: 30)),
                    onCompleted: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Text(
                    "Enter OTP",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              InkWell(
                onTap: () {
                  print("verifying otp");
                },
                child: InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => UserInformation()),
                    // );
                    _apiService.postOTP(widget.emailID, otp, context);
                  },
                  child: Container(
                    height: 50.h,
                    width: 198.w,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(38.r),
                    ),
                    child: Center(
                      child: Text(
                        "Verify OTP",
                        style: TextStyle(
                            fontSize: 28.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Didn't Recieve OTP?",
                style: TextStyle(fontSize: 16.sp),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }));
                      },
                      child: Text(
                        "CHANGE Email-Id",
                        style: TextStyle(fontSize: 16.sp),
                      )),
                  Text("or"),
                  TextButton(
                      onPressed: () async {
                        if (await _apiService.postEmail(
                            widget.emailID, context)) {}
                        ;
                      },
                      child: Text(
                        "RESEND CODE",
                        style: TextStyle(fontSize: 16.sp),
                      ))
                ],
              ),
            ],
          ),
        )));
  }
}
