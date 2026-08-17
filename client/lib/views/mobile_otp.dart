import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/core/providers/auth_provider.dart';
import 'package:papersafe/core/router/app_router.dart';
import 'package:papersafe/models/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

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
      final accessToken  = data['accessToken']  as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      if (doExist) {
        // Existing user → store user + tokens, go home
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        await ref.read(authProvider.notifier).login(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        if (mounted) context.go(AppRoutes.home);
      } else {
        // New user → go to onboarding
        if (mounted) {
          context.go('${AppRoutes.tellMore}/${Uri.encodeComponent(widget.emailID)}');
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Verify OTP',
              style: theme.textTheme.displaySmall,
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter the 6-digit code sent to\n${widget.emailID}',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 40.h),
            Center(
              child: Pinput(
                length: 6,
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  width: 50.w,
                  height: 55.h,
                  textStyle: theme.textTheme.headlineMedium,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 50.w,
                  height: 55.h,
                  textStyle: theme.textTheme.headlineMedium,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                onCompleted: (value) {
                  setState(() => _otp = value);
                  _verifyOtp();
                },
                onChanged: (value) => setState(() => _otp = value),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify OTP'),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Change Email'),
                ),
                const Text('or'),
                TextButton(
                  onPressed: () => _apiService.postEmail(widget.emailID, context),
                  child: const Text('Resend Code'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
