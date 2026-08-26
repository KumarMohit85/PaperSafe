import 'dart:async';

import 'package:papersafe/constants/colorManager.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:papersafe/models/image_model.dart';
import 'package:papersafe/views/view_documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentButton extends StatefulWidget {
  @override
  _DocumentButtonState createState() => _DocumentButtonState();
}

class _DocumentButtonState extends State<DocumentButton> {
  List<ImageModel?> list = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _startFetchingDocuments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFetchingDocuments() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      await _fetchDocuments();
      if (list.isNotEmpty) {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchDocuments() async {
    final docs = DocumentManager().allImages;
    if (docs.isNotEmpty) {
      setState(() {
        list = docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? _getCustomButton(Icons.pageview_outlined, "View All Documents", () async {
            print("all images list length = ${list.length}");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ViewDocuments(
                    documentCategory: DocumentCategory.all,
                    title: "All Documents",
                  );
                },
              ),
            );
          }, false)
        : _getCustomButton(null, "Downloading documents", () {}, true);
  }

  Widget _getCustomButton(
      IconData? icon, String text, VoidCallback func, bool isLoading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: isLoading ? null : func,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        height: 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF6C3DE3), Color(0xFF3D7BE3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isLoading
              ? (isDark ? Colors.white12 : Colors.grey.shade200)
              : null,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF6C3DE3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    color: isDark ? Colors.white54 : Colors.grey,
                    strokeWidth: 2.5,
                  ),
                )
              else if (icon != null)
                Icon(icon, color: Colors.white, size: 22.sp),
              SizedBox(
                width: 10.w,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isLoading
                      ? (isDark ? Colors.white38 : Colors.grey.shade500)
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
