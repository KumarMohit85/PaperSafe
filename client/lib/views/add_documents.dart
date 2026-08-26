import 'dart:async';
import 'dart:io';

import 'package:papersafe/views/add_document.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/views/homepage.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/models/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

enum documentType {
  Aadhaar,
  XMarkSheet,
  XIIMarkSheet,
  MovieTicket,
  PAN,
  TrainTicket
}

class AddDocuments extends StatefulWidget {
  const AddDocuments({super.key});

  @override
  State<AddDocuments> createState() => _AddDocumentsState();
}

class _AddDocumentsState extends State<AddDocuments> {
  User? _currentUser;

  @override
  void initState() {
    updateUser();
    super.initState();
  }

  void updateUser() async {
    _currentUser = await UserManager().getUser();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F0C20), Color(0xFF15102A), Color(0xFF0D0D14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF5F4FF), Color(0xFFEAEAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D14) : const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: _getAddDocuments(),
        ),
      ),
    );
  }

  Widget _getAddDocuments() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Documents",
            style: TextStyle(
              fontSize: 28.sp, 
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E1E40),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Most Added",
            style: TextStyle(
              fontSize: 16.sp, 
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/aadhar_logo.png", "Aadhar Card",
              () => getToPage(documentType.Aadhaar, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/marksheet.png", "Marksheet",
              () => getToPage(documentType.XMarkSheet, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/id_card_logo.png", "College ID",
              () => getToPage(documentType.MovieTicket, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/credit_card_logo.png", "PAN Card",
              () => getToPage(documentType.PAN, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/train_ticket.png", "Train Ticket",
              () => getToPage(documentType.TrainTicket, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 12.h),
          _getCustomButton("assets/images/movie_ticket.png", "Movie Ticket",
              () => getToPage(documentType.MovieTicket, _currentUser?.id ?? 'mock_user')),
          SizedBox(height: 20.h),
          Divider(
            thickness: 1.h,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getCustomSquare("assets/images/qr_code_logo.png", "Scan QR"),
              _getCustomSquare(
                  "assets/images/backup_logo.png", "Upload or Capture")
            ],
          ),
          SizedBox(height: 20.h),
          _getCustomButton(
              "assets/images/article_logo.png", "Form Fill-up", () {}),
        ],
      ),
    );
  }

  Widget _getCustomButton(String image, String text, VoidCallback func) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: func,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 52.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            width: 1.5,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Image.asset(
                image,
                height: 26.h,
                width: 30.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp, 
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1E40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCustomSquare(String image, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120.h,
      width: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1C3A).withOpacity(0.8), const Color(0xFF0F0E24).withOpacity(0.8)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          width: 1.5,
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Image.asset(
                image,
                height: 40.h,
                width: 40.h,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                height: 1.1,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E1E40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getToPage(documentType docType, String userId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AddDocument(docType: docType, id: userId);
    }));
  }
}
