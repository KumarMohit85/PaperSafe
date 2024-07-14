import 'dart:async';
import 'dart:io';

import 'package:_first_one/views/add_document.dart';
import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/views/homepage.dart';
import 'package:_first_one/models/user.dart';
import 'package:_first_one/models/user_manager.dart';
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
  File? _imageFile;

  @override
  void initState() {
    updateUser();
    super.initState();
  }

  void updateUser() async {
    _currentUser = await UserManager().getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _getAddDocuments(),
    );
  }

  Widget _getAddDocuments() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40.h,
            ),
            Text(
              "Add Documents",
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20.h),
            Text(
              "Most Added",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/aadhar_logo.png", "Aadhar Card",
                () => getToPage(documentType.Aadhaar, _currentUser!.id!)),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/marksheet.png", "Marksheet",
                () => getToPage(documentType.XMarkSheet, _currentUser!.id!)),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/id_card_logo.png", "College ID",
                () => getToPage(documentType.MovieTicket, _currentUser!.id!)),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/credit_card_logo.png", "PAN Card",
                () => getToPage(documentType.PAN, _currentUser!.id!)),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/train_ticket.png", "Train Ticket",
                () => getToPage(documentType.TrainTicket, _currentUser!.id!)),
            SizedBox(height: 13.h),
            _getCustomButton("assets/images/movie_ticket.png", "Movie Ticket",
                () => getToPage(documentType.MovieTicket, _currentUser!.id!)),
            SizedBox(height: 15.h),
            Divider(
              thickness: 3.h,
              color: Color.fromARGB(255, 113, 8, 122),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getCustomSquare("assets/images/qr_code_logo.png", "Scan QR"),
                _getCustomSquare(
                    "assets/images/backup_logo.png", "Upload Photo or Capture")
              ],
            ),
            SizedBox(height: 22.h),
            _getCustomButton(
                "assets/images/article_logo.png", "Form Fill-up", () {}),
          ],
        ),
      ),
    );
  }

  Widget _getCustomButton(String image, String text, VoidCallback func) {
    return InkWell(
      // onTap: () {
      //   _askSource(doc);
      // },
      onTap: func,
      child: Container(
        height: 45.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 227, 130, 244),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
                width: 2.5.sp, color: Color.fromARGB(255, 113, 8, 122))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.h, vertical: 4.h),
          child: Row(
            children: [
              Image.asset(
                image,
                height: 23.h,
                width: 40.h,
              ),
              Text(
                text,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
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

  _getCustomSquare(String image, String text) {
    return Container(
      height: 115.h,
      width: 120.h,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 227, 130, 244),
        borderRadius: BorderRadius.circular(30.r),
        border:
            Border.all(width: 2.5.sp, color: Color.fromARGB(255, 113, 8, 122)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Image.asset(
                image,
                height: 45.h,
                width: 45.h,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                  height: 0.9.h, fontSize: 20.sp, fontWeight: FontWeight.w500),
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
