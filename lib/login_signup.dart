import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/mobile_otp.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool agree = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  ApiService _apiService = ApiService();
  @override
  void dispose() {
    agree = false;
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 0),
          color: Colors.white,
          child: Column(
            children: [
              Text(
                "LOGIN OR SIGNUP",
                style: TextStyle(
                    fontSize: 38.sp, fontWeight: FontWeight.w700, height: 1.h),
                softWrap: true,
              ),
              SizedBox(
                height: 70.h,
              ),
              Container(
                  height: 123.h,
                  width: 125.w,
                  // color: Colors.purple[400],
                  child: Image.asset(
                    "assets/PaperSafeLogos/fill_inside_logo.png",
                    //color: Colors.purple,
                  )),
              SizedBox(
                height: 55.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          style: TextStyle(fontSize: 15, letterSpacing: 1.2.w),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon: Icon(Icons.mail),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                      width: 0, color: Colors.grey[200]!)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                  borderSide: BorderSide(
                                      width: 0, color: Colors.grey[200]!)),
                              hintText: "Enter your e-mail address",
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.w)),
                        ),
                      )),
                  SizedBox(
                    height: 3.h,
                  ),
                  Text(
                    "Email ID",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      agree
                          ? InkWell(
                              onTap: () => alterAgree(),
                              child: Icon(Icons.check_box))
                          : InkWell(
                              onTap: () => alterAgree(),
                              child: Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.purple,
                              )),
                      SizedBox(
                        height: 100.h,
                        width: 252.w,
                        child: Text(
                          "I Agree to Papersafe's Privacy and policy and Terms & conditions",
                          style: TextStyle(fontSize: 13.sp, height: 1.h),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: Text(
              //     "Next",
              //     style: TextStyle(
              //         color: Colors.white, fontWeight: FontWeight.w600),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.purple,
              //       padding: EdgeInsets.symmetric(horizontal: 44, vertical: 14),
              //       textStyle: TextStyle(
              //         fontSize: 25,
              //       )),
              // )
              InkWell(
                onTap: () {
                  _submit(_emailController.text);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => OtpVerification()),
                  // );
                },
                child: Container(
                  height: 40.h,
                  width: 162.w,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(38.r),
                  ),
                  child: Center(
                    child: Text(
                      "Next",
                      style: TextStyle(
                          fontSize: 28.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),

              _isLoading
                  ? CircularProgressIndicator()
                  : Container(), // Show loading indica
            ],
          ),
        ),
      ),
    );
  }

  //submit email and request otp
  void _submit(String emailID) async {
    if (agree) {
      setState(() {
        _isLoading = true;
      });
      var _isValid = _formKey.currentState?.validate();
      if (_isValid ?? false) {
        bool success = await _fetchOTP();
        success ? _goNext(emailID) : null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid details, fill again")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please agree to our policies")));
    }
  }

  _goNext(String emailID) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return OtpVerification(
        emailID: emailID,
      );
    }));
  }

  // Function to validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void alterAgree() {
    print("alter agree called");
    if (agree) {
      setState(() {
        agree = false;
      });
    } else {
      setState(() {
        agree = true;
      });
    }
  }

  _fetchOTP() async {
    try {
      return await _apiService.postEmail(_emailController.text, context);
    } catch (e) {
      print("there is a error ${e.toString()}");
      return false;
    }
  }
}
