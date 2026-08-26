import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:papersafe/core/widgets/glassmorphism.dart';
import 'package:papersafe/views/category_documents_page.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final List<Map<String, dynamic>> _categoryList = const [
    {
      "name": "Marksheets",
      "icon": Icons.description_outlined,
      "color": Color(0xFF4361EE),
      "desc": "10th, 12th & Degree Certificates",
    },
    {
      "name": "Credentials",
      "icon": Icons.shield_outlined,
      "color": Color(0xFF10B981),
      "desc": "Passports, Driving Licenses & Access Keys",
    },
    {
      "name": "Tickets",
      "icon": Icons.confirmation_num_outlined,
      "color": Color(0xFFEF4444),
      "desc": "Train, Flight & Event Passes",
    },
    {
      "name": "Cards",
      "icon": Icons.credit_card_outlined,
      "color": Color(0xFFF59E0B),
      "desc": "PAN, Credit & Banking Cards",
    },
    {
      "name": "Identity",
      "icon": Icons.remember_me_outlined,
      "color": Color(0xFF8B5CF6),
      "desc": "Aadhaar, Voter ID & National IDs",
    },
    {
      "name": "Education",
      "icon": Icons.school_outlined,
      "color": Color(0xFF06B6D4),
      "desc": "Diplomas & Academic Transcripts",
    },
    {
      "name": "Finance",
      "icon": Icons.currency_rupee_outlined,
      "color": Color(0xFF10B981),
      "desc": "Tax Invoices, Statements & Insurance",
    },
    {
      "name": "Travel",
      "icon": Icons.flight_takeoff_rounded,
      "color": Color(0xFFF97316),
      "desc": "Visas, Boarding Passes & Itineraries",
    },
    {
      "name": "Passes",
      "icon": Icons.vpn_key_outlined,
      "color": Color(0xFFEC4899),
      "desc": "Gym, Membership & Entry Badges",
    },
    {
      "name": "Health",
      "icon": Icons.health_and_safety_outlined,
      "color": Color(0xFF14B8A6),
      "desc": "Prescriptions, Reports & Vaccine Cards",
    },
    {
      "name": "Others",
      "icon": Icons.inventory_2_outlined,
      "color": Color(0xFF6B7280),
      "desc": "Miscellaneous Vault Items",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x224361EE),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOCUMENT CATEGORIES',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: const Color(0xFF8B9ABB),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Explore Vault',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categoryList.length,
                    itemBuilder: (context, index) {
                      final item = _categoryList[index];
                      return _buildCategoryBar(
                        item["name"] as String,
                        item["icon"] as IconData,
                        item["color"] as Color,
                        item["desc"] as String,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String title, IconData icon, Color color, String desc) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDocumentsPage(
              categoryName: title,
              categoryIcon: icon,
              accentColor: color,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B9ABB),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF8B9ABB),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
