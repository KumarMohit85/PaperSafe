import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/core/providers/auth_provider.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/models/user_manager.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kGreen = Color(0xFF22C55E);
const _kSubtext = Color(0xFF8B9ABB);
const _kCircle = Color(0xFF1A2D4A);

class ProfileDetailsPage extends ConsumerStatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  ConsumerState<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends ConsumerState<ProfileDetailsPage> {
  User? _user;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late Gender _selectedGender;
  DateTime? _selectedDate;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _selectedGender = Gender.male;
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = await UserManager().getUser();
    if (mounted) {
      setState(() {
        _user = user;
        if (user != null) {
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _emailController.text = user.emailId;
          _phoneController.text = user.mobileNumber.toString();
          _selectedDate = user.dob;
          _dobController.text = DateFormat('dd MMM yyyy').format(user.dob);
          _selectedGender = user.gender;
        } else {
          // Default mock user
          _firstNameController.text = 'Arjun';
          _lastNameController.text = 'Mehta';
          _emailController.text = 'arjun.mehta@gmail.com';
          _phoneController.text = '9876543210';
          _selectedDate = DateTime(1998, 5, 15);
          _dobController.text = DateFormat('dd MMM yyyy').format(_selectedDate!);
        }
      });
    }
  }

  Future<void> _selectDate() async {
    if (!_isEditing) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _kAccent,
              onPrimary: Colors.white,
              surface: _kSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      if (_user?.id != null) {
        await _apiService.updateUser(
          _user!.id!,
          {
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'mobileNumber': _phoneController.text.trim(),
            'emailID': _emailController.text.trim(),
            'dob': _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
            'gender': genderToString(_selectedGender),
          },
          context,
        );
      } else {
        // Save locally in mock mode
        final updatedUser = User(
          id: 'mock_user_1',
          schemaVersion: 1,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          mobileNumber: int.tryParse(_phoneController.text.trim()) ?? 9876543210,
          emailId: _emailController.text.trim(),
          dob: _selectedDate ?? DateTime(1998, 5, 15),
          gender: _selectedGender,
          uniqueId: 'PS-8849-UX',
        );
        UserManager().setUser(updatedUser);
      }

      await _loadProfile();
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();

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
              top: -50,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.7),
                ),
              ),
            ),
            // Bottom-left decorative circle
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.5),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Navigation Row ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                        Column(
                          children: [
                            Text(
                              'PROFILE DETAILS',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: _kSubtext,
                              ),
                            ),
                            Text(
                              'Account Info',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isEditing) {
                              _saveProfile();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: _isEditing ? _kAccent : _kSurface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _isEditing ? _kAccent : Colors.white12,
                              ),
                            ),
                            child: Text(
                              _isEditing ? 'Save' : 'Edit',
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

                    SizedBox(height: 28.h),

                    // ── Hero Profile Avatar & Badge Section ──────────────
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glassmorphic outer glow ring
                              Container(
                                width: 96.w,
                                height: 96.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kAccent.withOpacity(0.15),
                                  border: Border.all(
                                      color: _kAccent.withOpacity(0.4), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kAccent.withOpacity(0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              // Avatar icon
                              Container(
                                width: 84.w,
                                height: 84.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kSurface,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              // Verified Badge Overlay
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: _kGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.black,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            fullName.isEmpty ? 'PaperSafe User' : fullName,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _emailController.text,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _kSubtext,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _kGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: _kGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✦ ',
                                    style: TextStyle(
                                        color: _kGreen, fontSize: 11)),
                                Text(
                                  'PREMIUM VAULT MEMBER',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _kGreen,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // ── Card 1: Personal Information ────────────────────
                    _sectionHeader('Personal Information'),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildFormField(
                            label: 'First Name',
                            controller: _firstNameController,
                            icon: Icons.person_outline_rounded,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 14.h),
                          _buildFormField(
                            label: 'Last Name',
                            controller: _lastNameController,
                            icon: Icons.person_outline_rounded,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 16.h),
                          // Gender selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _kSubtext,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: Gender.values.map((g) {
                                  final isSelected = _selectedGender == g;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: _isEditing
                                          ? () =>
                                              setState(() => _selectedGender = g)
                                          : null,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 4.w),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _kAccent
                                              : _kElevated,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          border: Border.all(
                                            color: isSelected
                                                ? _kAccent
                                                : Colors.white10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            g.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : _kSubtext,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Card 2: Contact & Identity ─────────────────────
                    _sectionHeader('Contact & Identity'),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildFormField(
                            label: 'Email Address',
                            controller: _emailController,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 14.h),
                          _buildFormField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            enabled: _isEditing,
                          ),
                          SizedBox(height: 14.h),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: _buildFormField(
                                label: 'Date of Birth',
                                controller: _dobController,
                                icon: Icons.calendar_today_rounded,
                                enabled: _isEditing,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ── Update CTA Button (when editing) ───────────────
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Save Profile Changes',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                    SizedBox(height: 16.h),

                    // Logout & Danger options
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.logout_rounded,
                                color: Colors.redAccent, size: 18),
                            label: const Text('Log Out',
                                style: TextStyle(color: Colors.redAccent)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.4)),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: _kSubtext,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14.sp,
            color: enabled ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? _kElevated : _kElevated.withOpacity(0.5),
            prefixIcon: Icon(icon, color: enabled ? _kAccent : _kSubtext, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: enabled ? Colors.white24 : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: _kAccent, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
