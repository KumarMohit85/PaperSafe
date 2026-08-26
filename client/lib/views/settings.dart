import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:papersafe/core/providers/biometric_provider.dart';
import 'package:papersafe/core/providers/auth_provider.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/models/user_manager.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:papersafe/views/terms_n_conditions.dart';
import 'package:papersafe/views/profile_details_page.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kGreen = Color(0xFF22C55E);
const _kSubtext = Color(0xFF8B9ABB);
const _kCircle = Color(0xFF1A2D4A);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  User? _currentUser;
  bool _autoLockOnMinimize = true;
  bool _hidePreviews = false;
  bool _darkTheme = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserManager().getUser();
    if (mounted && user != null) {
      setState(() => _currentUser = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBiometricEnabled = ref.watch(biometricEnabledProvider);
    final userName = _currentUser != null
        ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
        : 'Arjun Mehta';
    final userEmail = _currentUser?.emailId.isNotEmpty == true
        ? _currentUser!.emailId
        : 'arjun.mehta@gmail.com';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: Stack(
          children: [
            // Top-right decorative circle
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.7),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: _kSubtext,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Profile Card ────────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: _kElevated,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: _kSubtext,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _kSubtext,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: _kGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                        color: _kGreen.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('✦ ',
                                          style: TextStyle(
                                              color: _kGreen, fontSize: 10)),
                                      Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _kGreen,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileDetailsPage(),
                                ),
                              ).then((_) => _loadUser());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _kElevated,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ── Local Storage Progress Card ─────────────────────
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sd_storage_outlined,
                                  color: _kSubtext, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Local storage',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: 14.2 / 500.0,
                              backgroundColor: _kElevated,
                              color: _kAccent,
                              minHeight: 6.h,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '14.2 MB used',
                                style: TextStyle(
                                    fontSize: 12.sp, color: _kSubtext),
                              ),
                              Text(
                                'of 500 MB',
                                style: TextStyle(
                                    fontSize: 12.sp, color: _kSubtext),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Security Group ──────────────────────────────────
                    _sectionHeader('Security'),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _switchItem(
                            icon: Icons.fingerprint_rounded,
                            iconBg: _kGreen.withOpacity(0.15),
                            iconColor: _kGreen,
                            title: 'Biometric lock',
                            subtitle: 'Require FaceID / fingerprint on launch',
                            value: isBiometricEnabled,
                            onChanged: (val) async {
                              final bioService = ref.read(biometricServiceProvider);
                              if (val) {
                                final canAuth = await bioService.canAuthenticate();
                                if (!canAuth) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Biometric hardware not available.')),
                                    );
                                  }
                                  return;
                                }
                                final authenticated = await bioService.authenticate(
                                  localizedReason: 'Confirm biometrics to enable vault protection',
                                );
                                if (authenticated) {
                                  await ref
                                      .read(biometricEnabledProvider.notifier)
                                      .toggleBiometrics(true);
                                }
                              } else {
                                await ref
                                    .read(biometricEnabledProvider.notifier)
                                    .toggleBiometrics(false);
                              }
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _switchItem(
                            icon: Icons.shield_outlined,
                            iconBg: _kAccent.withOpacity(0.15),
                            iconColor: _kAccent,
                            title: 'Auto-lock on minimize',
                            subtitle: 'Re-lock when app goes to background',
                            value: _autoLockOnMinimize,
                            onChanged: (val) =>
                                setState(() => _autoLockOnMinimize = val),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _switchItem(
                            icon: Icons.visibility_off_outlined,
                            iconBg: Colors.purple.withOpacity(0.15),
                            iconColor: Colors.purpleAccent,
                            title: 'Hide previews',
                            subtitle: 'Hide document thumbnails in recents',
                            value: _hidePreviews,
                            onChanged: (val) =>
                                setState(() => _hidePreviews = val),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Preferences Group ───────────────────────────────
                    _sectionHeader('Preferences'),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _switchItem(
                            icon: Icons.dark_mode_outlined,
                            iconBg: _kAccent.withOpacity(0.15),
                            iconColor: _kAccent,
                            title: 'Dark theme',
                            subtitle: 'Match system appearance',
                            value: _darkTheme,
                            onChanged: (val) =>
                                setState(() => _darkTheme = val),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _switchItem(
                            icon: Icons.notifications_none_rounded,
                            iconBg: Colors.amber.withOpacity(0.15),
                            iconColor: Colors.amber,
                            title: 'Notifications',
                            subtitle: 'Document expiry & share alerts',
                            value: _notifications,
                            onChanged: (val) =>
                                setState(() => _notifications = val),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── More Group ──────────────────────────────────────
                    _sectionHeader('More'),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _navItem(
                            icon: Icons.palette_outlined,
                            iconBg: Colors.purple.withOpacity(0.15),
                            iconColor: Colors.purpleAccent,
                            title: 'Appearance',
                            subtitle: 'Themes & accent colors',
                            onTap: () {},
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _navItem(
                            icon: Icons.help_outline_rounded,
                            iconBg: Colors.amber.withOpacity(0.15),
                            iconColor: Colors.amber,
                            title: 'Help & support',
                            subtitle: 'FAQs and contact',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => TermsAndConditions()),
                              );
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _navItem(
                            icon: Icons.info_outline_rounded,
                            iconBg: _kAccent.withOpacity(0.15),
                            iconColor: _kAccent,
                            title: 'About PaperSafe',
                            subtitle: 'Version 1.0.0',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Action Row (Clear Vault / Sign Out) ─────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _confirmClearVault(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Clear vault',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await ref.read(authProvider.notifier).logout();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded,
                                      color: Colors.white70, size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Sign out',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // ── Footer ──────────────────────────────────────────
                    Center(
                      child: Text(
                        'PaperSafe · Built for privacy',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _kSubtext,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _switchItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: _kSubtext,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: _kAccent,
              activeTrackColor: _kAccent.withOpacity(0.3),
              inactiveThumbColor: _kSubtext,
              inactiveTrackColor: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _kSubtext,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: _kSubtext, size: 14),
          ],
        ),
      ),
    );
  }

  void _confirmClearVault() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Clear Vault', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete all locally stored documents? This action cannot be undone.',
          style: TextStyle(color: _kSubtext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton(
            onPressed: () {
              DocumentManager().allImages.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vault cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
