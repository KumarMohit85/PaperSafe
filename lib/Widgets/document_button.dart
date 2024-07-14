import 'dart:async';

import 'package:_first_one/constants/colorManager.dart';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:_first_one/views/view_documents.dart';
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
    _startFetchingDocuments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFetchingDocuments() {
    _timer = Timer.periodic(Duration(microseconds: 100), (timer) async {
      await _fetchDocuments();
      if (list.isNotEmpty) {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchDocuments() async {
    list = DocumentManager().allImages;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? _getCustomButton(Icons.pageview_outlined, "View All Documents",
            () async {
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
        // ? ElevatedButton(
        //     onPressed: () async {
        //       print("all images list length = ${list.length}");

        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) {
        //             return ViewDocuments(
        //               list: list,
        //               title: "All Documents",
        //             );
        //           },
        //         ),
        //       );
        //     },
        //     child: const Text("View all Documents"),
        //   )

        : _getCustomButton(null, "Downloading documents", () {}, true);
  }

  Widget _getCustomButton(
      IconData? icon, String text, VoidCallback func, bool isLoading) {
    return InkWell(
      // onTap: () {
      //   _askSource(doc);
      // },
      onTap: func,
      child: Container(
        height: 45.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: isLoading
                ? Color.fromARGB(255, 241, 228, 238)
                : Color.fromARGB(255, 227, 130, 244),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
                width: 2.5.sp,
                color: isLoading
                    ? Color.fromARGB(255, 231, 167, 243)
                    : Color.fromARGB(255, 113, 8, 122))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.h, vertical: 4.h),
          child: Row(
            children: [
              isLoading
                  ? CircularProgressIndicator(
                      color: Colors.grey,
                    )
                  : Icon(icon),
              SizedBox(
                width: 10.w,
              ),
              Text(
                text,
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: isLoading ? Colors.grey : ColorManager().primary),
              ),
              SizedBox(
                height: 30.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
