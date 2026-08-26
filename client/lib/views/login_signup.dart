import 'dart:ui';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/views/mobile_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Design constants
const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kAccent = Color(0xFF4361EE);
const _kCircle = Color(0xFF1A2D4A);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: Stack(
          children: [
            // Decorative blurred circle — top right
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.8),
                ),
              ),
            ),
            // Decorative blurred circle — bottom left
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.6),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),

                    // Shield icon in rounded square
                    Center(
                      child: Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: _kAccent,
                          size: 34.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // App name & subtitle
                    Center(
                      child: Text(
                        'PaperSafe',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Your private document vault',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF8B9ABB),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Welcome heading
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Enter your email to sign in or create an account. We'll send you a one-time code to verify it's you.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF8B9ABB),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Email label
                    Text(
                      'Email address',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Email input
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _kSurface,
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF8B9ABB),
                          ),
                          hintText: 'you@example.com',
                          hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: _kAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Continue button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: _kAccent))
                        : SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: () => _submit(_emailController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),

                    SizedBox(height: 32.h),

                    // Info card
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: _kAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: const Icon(Icons.shield_outlined, color: _kAccent, size: 18),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Your email stays on your device. No cloud, no tracking.',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF8B9ABB),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String emailID) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      final success = await _apiService.postEmail(emailID, context);
      if (success == true && mounted) {
        _goNext(emailID);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goNext(String emailID) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      return OtpVerification(emailID: emailID);
    }));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }
}
