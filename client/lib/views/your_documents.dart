import 'dart:async';
import 'package:flutter/services.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/models/aadhar_frame.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:papersafe/models/pan_frame.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/models/user_manager.dart';
import 'package:papersafe/views/add_documents.dart';
import 'package:papersafe/views/category_documents_page.dart';
import 'package:papersafe/views/login_signup.dart';
import 'package:papersafe/views/profile_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CardType { pan, aadhaar }

// Design tokens
const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kGreen = Color(0xFF22C55E);
const _kCircle = Color(0xFF1A2D4A);

class YourDocuments extends StatefulWidget {
  const YourDocuments({super.key});

  @override
  State<YourDocuments> createState() => _YourDocumentsState();
}

class _YourDocumentsState extends State<YourDocuments> {
  User? _currentUser;
  final ApiService _apiService = ApiService();
  int _cardIndex = 0;

  // Profile editing controllers (kept for drawer)
  bool _enableEditing = false;
  DateTime? selectedDate = DateTime.now();
  late TextEditingController _date;
  late TextEditingController _month;
  late TextEditingController _year;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileNoController;
  late TextEditingController _emailController;
  late Gender _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = Gender.male;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _mobileNoController = TextEditingController();
    _emailController = TextEditingController();
    _date = TextEditingController(text: DateTime.now().day.toString());
    _month = TextEditingController(text: DateTime.now().month.toString());
    _year = TextEditingController(text: DateTime.now().year.toString());
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNoController.dispose();
    _emailController.dispose();
    _date.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await UserManager().getUser();
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
        _selectedGender = user.gender;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _mobileNoController.text = user.mobileNumber.toString();
        _emailController.text = user.emailId;
        _date.text = user.dob.day.toString();
        _month.text = user.dob.month.toString();
        _year.text = user.dob.year.toString();
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName =>
      _currentUser?.firstName.isNotEmpty == true ? _currentUser!.firstName : 'there';

  @override
  Widget build(BuildContext context) {
    final docs = DocumentManager().allImages;
    final totalDocs = docs.length;
    final idCards = (AadharFrame().isAadharAvailable() ? 1 : 0) +
        (PanFrame().isPanAvailable() ? 1 : 0);
    const isBioOn = true; // Mock — actual value comes from biometric provider

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Decorative circles
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
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRIVATE SPACE',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: const Color(0xFF8B9ABB),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$_greeting, $_firstName',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _kSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF8B9ABB),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Stats Row ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      _statCard('$totalDocs', 'Documents'),
                      SizedBox(width: 10.w),
                      _statCard('$idCards', 'ID cards'),
                      SizedBox(width: 10.w),
                      _statCardHighlight(isBioOn ? 'On' : 'Off', 'Biometric', isBioOn),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Scrollable body ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Identity cards section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Identity cards',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                              GestureDetector(
                                onTap: _askFrame,
                                child: Text('See all >',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: _kAccent,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Card carousel
                        SizedBox(
                          height: 155.h,
                          child: PageView(
                            controller: PageController(viewportFraction: 0.88),
                            onPageChanged: (i) => setState(() => _cardIndex = i),
                            children: [
                              _buildIdCard(
                                number: AadharFrame().isAadharAvailable()
                                    ? AadharFrame().aadharNumber ?? 'XXXX XXXX 4827'
                                    : 'XXXX XXXX 4827',
                                holder: _currentUser != null
                                    ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                                    : 'Arjun Mehta',
                                type: 'Aadhaar Card',
                                verified: AadharFrame().isAadharAvailable(),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E3A5F), Color(0xFF2D4E7A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () {
                                  final num = AadharFrame().isAadharAvailable()
                                      ? AadharFrame().aadharNumber ?? 'XXXX XXXX 4827'
                                      : 'XXXX XXXX 4827';
                                  final name = _currentUser != null
                                      ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                                      : 'Arjun Mehta';
                                  _showMaximizedCardDetails(
                                    type: 'Aadhaar Card',
                                    number: num,
                                    holder: name,
                                    verified: AadharFrame().isAadharAvailable(),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1E3A5F), Color(0xFF2D4E7A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    imageBytes: DocumentManager().getDocument("aadhaar"),
                                  );
                                },
                              ),
                              _buildIdCard(
                                number: PanFrame().isPanAvailable()
                                    ? PanFrame().panNumber ?? 'ABCDE1234F'
                                    : 'ABCDE1234F',
                                holder: _currentUser != null
                                    ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                                    : 'Arjun Mehta',
                                type: 'PAN Card',
                                verified: PanFrame().isPanAvailable(),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3A1E5F), Color(0xFF5E2D7A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onTap: () {
                                  final num = PanFrame().isPanAvailable()
                                      ? PanFrame().panNumber ?? 'ABCDE1234F'
                                      : 'ABCDE1234F';
                                  final name = _currentUser != null
                                      ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                                      : 'Arjun Mehta';
                                  _showMaximizedCardDetails(
                                    type: 'PAN Card',
                                    number: num,
                                    holder: name,
                                    verified: PanFrame().isPanAvailable(),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3A1E5F), Color(0xFF5E2D7A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    imageBytes: DocumentManager().getDocument("pan"),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Dots indicator
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [0, 1].map((i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _cardIndex == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _cardIndex == i ? _kAccent : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 24.h),

                        // Categories
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text('Categories',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                        ),
                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 1.5,
                            children: [
                              _categoryTile(Icons.description_outlined, 'Marksheets', 6,
                                  const Color(0xFF4361EE)),
                              _categoryTile(Icons.shield_outlined, 'Credentials', 4,
                                  const Color(0xFF10B981)),
                              _categoryTile(Icons.confirmation_num_outlined, 'Tickets', 3,
                                  const Color(0xFFEF4444)),
                              _categoryTile(Icons.credit_card_outlined, 'Cards', 5,
                                  const Color(0xFFF59E0B)),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Recently added
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recently added',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                              Text('View all >',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: _kAccent,
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Recent docs list — top 3 from DocumentManager
                        _buildRecentList(docs),

                        SizedBox(height: 16.h),

                        // Add Document button
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => AddDocuments()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.crop_free_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scan a new document',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('✦', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
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
        ],
      ),
    );
  }

  void _showMaximizedCardDetails({
    required String type,
    required String number,
    required String holder,
    required bool verified,
    required Gradient gradient,
    Uint8List? imageBytes,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Card Details',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFF131D30),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: verified ? const Color(0xFF22C55E) : const Color(0xFF4361EE),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Maximized Card Visual
                    Container(
                      width: double.infinity,
                      height: 185.h,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 38,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.credit_card, color: Colors.white70, size: 18),
                              ),
                              if (verified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF22C55E)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_outlined, color: const Color(0xFF22C55E), size: 13.sp),
                                      const SizedBox(width: 4),
                                      Text(
                                        'VERIFIED',
                                        style: TextStyle(
                                          color: const Color(0xFF22C55E),
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          SelectableText(
                            number,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2.5,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CARDHOLDER NAME',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.white60,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    holder,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Scanned Image (if available)
                    if (imageBytes != null) ...[
                      Container(
                        height: 150.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Info Table
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2540),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _detailRow('Card Type', type),
                          const Divider(color: Colors.white10, height: 12),
                          _detailRow('Number', number),
                          const Divider(color: Colors.white10, height: 12),
                          _detailRow('Holder', holder),
                          const Divider(color: Colors.white10, height: 12),
                          _detailRow('Encryption', 'AES-256 (Hardware Vault)'),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: number));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$type number copied to clipboard!'),
                                  backgroundColor: const Color(0xFF4361EE),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                            label: Text(
                              'Copy Number',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4361EE),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text('Close', style: TextStyle(fontSize: 13.sp)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8B9ABB)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
            Text(label,
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8B9ABB))),
          ],
        ),
      ),
    );
  }

  Widget _statCardHighlight(String value, String label, bool active) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: active ? _kGreen : Colors.white54,
                )),
            Text(label,
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8B9ABB))),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard({
    required String number,
    required String holder,
    required String type,
    required bool verified,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18.r),
        ),
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chip icon
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (verified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kGreen.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined, color: _kGreen, size: 12.sp),
                        const SizedBox(width: 4),
                        Text('Verified',
                            style: TextStyle(
                              color: _kGreen,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              number,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARDHOLDER',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        )),
                    Text(holder,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ],
                ),
                Text(type,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(IconData icon, String name, int count, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDocumentsPage(
              categoryName: name,
              categoryIcon: icon,
              accentColor: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white10),
        ),
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text('$count items',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B9ABB),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(List<dynamic> docs) {
    final recent = docs.take(3).toList();
    if (recent.isEmpty) {
      // Fallback mock list
      final mockItems = [
        ('Degree Marksheet', 'PDF · 2.4 MB', Icons.description_outlined, const Color(0xFF4361EE)),
        ('Flight ticket — BLR → DEL', 'PDF · 860 KB', Icons.confirmation_num_outlined, const Color(0xFFEF4444)),
        ('Vaccination certificate', 'PDF · 1.1 MB', Icons.shield_outlined, const Color(0xFF10B981)),
      ];
      return Column(
        children: mockItems
            .map<Widget>((item) => _recentItem(item.$1, item.$2, item.$3, item.$4))
            .toList(),
      );
    }
    return Column(
      children: recent.map<Widget>((doc) {
        if (doc == null) return const SizedBox.shrink();
        final title = (doc as dynamic).title as String? ?? 'Document';
        return _recentItem(
          title,
          'Saved locally',
          Icons.description_outlined,
          _kAccent,
        );
      }).toList(),
    );
  }

  Widget _recentItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B9ABB),
                    )),
              ],
            ),
          ),
          const Icon(Icons.arrow_outward, color: Color(0xFF8B9ABB), size: 16),
        ],
      ),
    );
  }

  // ── Profile bottom sheet ──────────────────────────────────────────
  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Profile',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            SizedBox(height: 16.h),
            Text(
              _currentUser != null
                  ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
                  : 'Guest',
              style: TextStyle(fontSize: 16.sp, color: Colors.white70),
            ),
            Text(
              _currentUser?.emailId ?? '',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF8B9ABB)),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartApp(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: Colors.red.withOpacity(0.4)),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restartApp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ── Add card flow ──────────────────────────────────────────────────
  void _askFrame() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Identity Card',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            SizedBox(height: 16.h),
            _cardOption('Aadhaar', 'assets/images/aadhar_logo.png', () {
              Navigator.pop(context);
              _addFrame(CardType.aadhaar);
            }),
            SizedBox(height: 10.h),
            _cardOption('PAN Card', 'assets/images/id_card_logo.png', () {
              Navigator.pop(context);
              _addFrame(CardType.pan);
            }),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _cardOption(String label, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _kElevated,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Image.asset(assetPath, width: 28.w, height: 20.h, fit: BoxFit.contain),
            SizedBox(width: 14.w),
            Text(label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B9ABB), size: 14),
          ],
        ),
      ),
    );
  }

  void _addFrame(CardType cardType) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, MediaQuery.of(context).viewInsets.bottom + 24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter ${cardType == CardType.aadhaar ? "Aadhaar" : "PAN"} Number',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: _kElevated,
                hintText: cardType == CardType.aadhaar ? 'XXXX XXXX XXXX' : 'ABCDE1234F',
                hintStyle: const TextStyle(color: Color(0xFF8B9ABB)),
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
                  borderSide: const BorderSide(color: _kAccent),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  _setDetails(cardType, controller.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setDetails(CardType cardType, String number) {
    final fullName = _currentUser != null
        ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
        : 'User';
    switch (cardType) {
      case CardType.pan:
        PanFrame().setDetails(number, fullName, DateTime.now());
      case CardType.aadhaar:
        AadharFrame().setDetails(number, fullName, DateTime.now());
    }
    setState(() {});
  }

  Future<void> selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        _date.text = selected.day.toString();
        _month.text = selected.month.toString();
        _year.text = selected.year.toString();
      });
    }
  }
}
