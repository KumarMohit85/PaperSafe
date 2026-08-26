import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/core/providers/auth_provider.dart';
import 'package:papersafe/core/router/app_router.dart';
import 'package:papersafe/models/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kAccent = Color(0xFF4361EE);
const _kCircle = Color(0xFF1A2D4A);

/// GoRouter-compatible alias for the OTP screen.
class MobileOtpPage extends StatelessWidget {
  const MobileOtpPage({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => OtpVerification(emailID: email);
}

class OtpVerification extends ConsumerStatefulWidget {
  const OtpVerification({super.key, required this.emailID});
  final String emailID;

  @override
  ConsumerState<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends ConsumerState<OtpVerification> {
  final ApiService _apiService = ApiService();
  String _otp = '';
  bool _loading = false;
  int _resendCountdown = 23;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendCountdown = 23;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await _apiService.postOTP(widget.emailID, _otp, context);

      if (data == null) {
        setState(() => _loading = false);
        return;
      }

      final doExist = data['doExist'] as bool? ?? false;
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      if (doExist) {
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        await ref.read(authProvider.notifier).login(
              user: user,
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
        if (mounted) context.go(AppRoutes.home);
      } else {
        if (mounted) {
          context.go('${AppRoutes.tellMore}/${Uri.encodeComponent(widget.emailID)}');
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length <= 2
        ? name
        : '${name.substring(0, 2)}${'*' * (name.length - 2)}';
    return '$masked@${parts[1]}';
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
            // Decorative circle — top right
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.8),
                ),
              ),
            ),
            // Decorative circle — bottom left
            Positioned(
              bottom: 120,
              left: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.6),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),

                    // Back button
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Mail icon in rounded square — centered
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
                          Icons.mail_outline_rounded,
                          color: _kAccent,
                          size: 34.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Title
                    Center(
                      child: Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8B9ABB), height: 1.5),
                          children: [
                            const TextSpan(text: 'We sent a 6-digit code to\n'),
                            TextSpan(
                              text: _maskEmail(widget.emailID),
                              style: const TextStyle(
                                color: _kAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 36.h),

                    // 6 OTP boxes
                    Center(
                      child: Pinput(
                        length: 6,
                        keyboardType: TextInputType.number,
                        defaultPinTheme: PinTheme(
                          width: 48.w,
                          height: 54.h,
                          textStyle: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white12),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 48.w,
                          height: 54.h,
                          textStyle: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: _kAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _kAccent.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 48.w,
                          height: 54.h,
                          textStyle: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: _kAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: _kAccent.withOpacity(0.5)),
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() => _otp = value);
                          _verifyOtp();
                        },
                        onChanged: (value) => setState(() => _otp = value),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Verify button
                    _loading
                        ? const Center(child: CircularProgressIndicator(color: _kAccent))
                        : SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: _verifyOtp,
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
                                    'Verify code',
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

                    SizedBox(height: 16.h),

                    // Resend countdown
                    Center(
                      child: _resendCountdown > 0
                          ? Text(
                              'Resend code in ${_resendCountdown}s',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF8B9ABB),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                _apiService.postEmail(widget.emailID, context);
                                _startResendTimer();
                              },
                              child: Text(
                                'Resend code',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _kAccent,
                                  fontWeight: FontWeight.w600,
                                ),
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
                              'The code expires in 10 minutes. Never share it with anyone.',
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
}
