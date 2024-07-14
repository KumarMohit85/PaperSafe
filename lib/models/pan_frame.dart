import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanFrame {
  // Fields to store PAN number, username, and date created
  String? panNumber;
  String? username;
  DateTime? dateCreated;

  // Private constructor
  PanFrame._privateConstructor();

  // The single instance of the class
  static final PanFrame _instance = PanFrame._privateConstructor();

  // Factory constructor to return the single instance
  factory PanFrame() {
    return _instance;
  }

  Future<void> setDetails(
      String panNumber, String username, DateTime dateCreated) async {
    this.panNumber = panNumber;
    this.username = username;
    this.dateCreated = dateCreated;

    // Save details to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('panNumber', panNumber);
    await prefs.setString('username', username);
    await prefs.setString('dateCreated', dateCreated.toIso8601String());
  }

  // Method to load details from shared preferences
  Future<void> loadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    panNumber = prefs.getString('panNumber');
    username = prefs.getString('username');
    dateCreated = prefs.getString('dateCreated') != null
        ? DateTime.parse(prefs.getString('dateCreated')!)
        : null;
  }

  // Method to check if PAN card details are available
  bool isPanAvailable() {
    return panNumber != null && username != null && dateCreated != null;
  }

  // Method to get PAN card layout
  Widget getPanCardLayout() {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/images/pan_card_frame.svg",
          height: 170.h,
          width: 270.w,
        ),
        Positioned(
          left: 40.w,
          top: 55.h,
          child: Row(
            children: [
              Text(
                panNumber!,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: panNumber!));
                },
                child: Icon(
                  Icons.copy,
                  color: Colors.grey[800],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 30.h,
          left: 10.h,
          child: const Text(
            "Issued Locally",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 18.h,
          left: 10.w,
          child: Text(
            formatter.format(dateCreated!),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
            right: 20.w,
            bottom: 32.h,
            child: Text(username!,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Positioned(
            bottom: 12,
            right: 15,
            child: Image.asset(
              "assets/PaperSafeLogos/paper_safe_same_gradient.png",
              height: 45,
              width: 70,
            ))
      ],
    );
  }
}
