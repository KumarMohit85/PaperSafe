import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/views/homepage.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/core/widgets/glassmorphism.dart';
import 'package:papersafe/core/theme/app_colors.dart';
import 'package:papersafe/core/router/app_router.dart';
import 'package:papersafe/core/providers/auth_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserInformation extends ConsumerStatefulWidget {
  const UserInformation({super.key, required this.email});
  final String email;

  @override
  ConsumerState<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends ConsumerState<UserInformation> {
  Gender _selectedGender = Gender.male;
  bool _isLoading = false;
  DateTime? selectedDate = DateTime.now();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _mobileNo = TextEditingController();
  
  late final TextEditingController _date;
  late final TextEditingController _month;
  late final TextEditingController _year;

  @override
  void initState() {
    super.initState();
    _date = TextEditingController(text: DateTime.now().day.toString());
    _month = TextEditingController(text: DateTime.now().month.toString());
    _year = TextEditingController(text: DateTime.now().year.toString());
  }

  Future<void> selectDate() async {
    DateTime? selected = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(DateTime.now().year + 1),
        initialDate: DateTime.now());
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        _date.text = selected.day.toString();
        _month.text = selected.month.toString();
        _year.text = selected.year.toString();
      });
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobileNo.dispose();
    _date.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F0C20), Color(0xFF15102A), Color(0xFF0D0D14)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFEAEAFF), Color(0xFFF3F2FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => context.go(AppRoutes.login),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Tell Us More",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF1E1E40),
                  ),
                ),
                Text(
                  "Complete your secure profile",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Onboarding Glass Card
                GlassMorphism(
                  padding: EdgeInsets.all(24.r),
                  borderRadius: 24,
                  blurSigma: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _firstName,
                        label: "First Name",
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _lastName,
                        label: "Last Name",
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _mobileNo,
                        label: "Mobile Number",
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                      ),
                      SizedBox(height: 16.h),
                      
                      // DOB Section
                      Text(
                        "Date of Birth",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDOBField(controller: _date, hint: "Day", isDark: isDark),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildDOBField(controller: _month, hint: "Month", isDark: isDark),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildDOBField(controller: _year, hint: "Year", isDark: isDark),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            onPressed: selectDate,
                            icon: Icon(
                              Icons.calendar_month_rounded,
                              size: 28.r,
                              color: AppColors.accent,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20.h),
                      
                      // Gender Section
                      Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: Gender.values.map((Gender gender) {
                          final isSelected = _selectedGender == gender;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              height: 44.h,
                              width: 82.w,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent.withOpacity(0.2)
                                    : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: Text(
                                  gender.toString().split('.').last.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark ? AppColors.accentLight : AppColors.accent)
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Save Button
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : InkWell(
                              onTap: () async {
                                if (_firstName.text.isEmpty || _lastName.text.isEmpty || _mobileNo.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all details')),
                                  );
                                  return;
                                }
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final ApiService apiService = ApiService();
                                  final data = await apiService.postNewUser(
                                    firstName: _firstName.text,
                                    lastName: _lastName.text,
                                    mobNo: _mobileNo.text,
                                    gender: genderToString(_selectedGender),
                                    emailId: widget.email,
                                    dob: selectedDate!.toIso8601String(),
                                    context: context,
                                  );

                                  if (data != null) {
                                    final user = User.fromJson(data['user'] as Map<String, dynamic>);
                                    final accessToken = data['accessToken'] as String? ?? '';
                                    final refreshToken = data['refreshToken'] as String? ?? '';
                                    
                                    await ref.read(authProvider.notifier).login(
                                      user: user,
                                      accessToken: accessToken,
                                      refreshToken: refreshToken,
                                    );
                                    if (mounted) {
                                      context.go(AppRoutes.home);
                                    }
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(25.r),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C3DE3), Color(0xFF3D7BE3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Container(
                                  height: 50.h,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Save & Continue",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            hintText: "Enter your $label",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDOBField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15.sp,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white30 : Colors.black38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
      ),
    );
  }
}
