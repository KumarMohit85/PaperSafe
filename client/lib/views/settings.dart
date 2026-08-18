import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:papersafe/core/providers/biometric_provider.dart';
import 'package:papersafe/core/providers/auth_provider.dart';
import 'package:papersafe/views/delete_documents.dart';
import 'package:papersafe/views/terms_n_conditions.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isBiometricEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              _getSubHeading("App Preferences & Security"),
              const SizedBox(height: 12),
              
              // Biometric Toggle Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Biometric App Lock",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Require Fingerprint or Face ID when opening PaperSafe",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  secondary: const Icon(Icons.fingerprint, color: Colors.tealAccent),
                  value: isBiometricEnabled,
                  activeColor: Colors.tealAccent,
                  onChanged: (bool value) async {
                    if (value) {
                      final bioService = ref.read(biometricServiceProvider);
                      final canAuth = await bioService.canAuthenticate();
                      if (!canAuth) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Biometric hardware is not available on this device.'),
                            ),
                          );
                        }
                        return;
                      }
                      final authenticated = await bioService.authenticate(
                        localizedReason: 'Confirm biometrics to enable vault protection',
                      );
                      if (authenticated) {
                        await ref.read(biometricEnabledProvider.notifier).toggleBiometrics(true);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Biometric lock enabled!')),
                          );
                        }
                      }
                    } else {
                      await ref.read(biometricEnabledProvider.notifier).toggleBiometrics(false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometric lock disabled.')),
                        );
                      }
                    }
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Manage & Delete Documents
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManageDocuments(title: "Delete Documents"),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      SizedBox(width: 16),
                      Text(
                        "Manage / Delete Documents",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Spacer(),
                      Icon(CupertinoIcons.chevron_forward, color: Colors.white38),
                    ],
                  ),
                ),
              ),

              _getDivider(),
              _getSubHeading("Need Help?"),
              SizedBox(height: 12.h),

              _listButton("Terms & Conditions", Icons.article_outlined, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TermsAndConditions()),
                );
              }),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 30.h),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80.h,
                        width: 85.w,
                        child: Image.asset("assets/PaperSafeLogos/paper_safe_gradient.png"),
                      ),
                      SizedBox(height: 8.h),
                      const Text(
                        "PaperSafe v2.0.0 – AI Powered Vault",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSubHeading(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.tealAccent),
      ),
    );
  }

  Widget _listButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(CupertinoIcons.chevron_forward, color: Colors.white38, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _getDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Divider(thickness: 1, color: Colors.white12),
    );
  }
}
