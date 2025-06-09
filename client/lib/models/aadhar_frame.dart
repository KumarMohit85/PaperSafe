import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AadharFrame {
  // Fields to store Aadhar number, username, and date created
  String? aadharNumber;
  String? username;
  DateTime? dateCreated;

  // Private constructor
  AadharFrame._privateConstructor();

  // The single instance of the class
  static final AadharFrame _instance = AadharFrame._privateConstructor();

  // Factory constructor to return the single instance
  factory AadharFrame() {
    return _instance;
  }

  // Method to set Aadhar number, username, and date created
  Future<void> setDetails(
      String aadharNumber, String username, DateTime dateCreated) async {
    this.aadharNumber = aadharNumber;
    this.username = username;
    this.dateCreated = dateCreated;

    // Save details to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('aadharNumber', aadharNumber);
    await prefs.setString('username', username);
    await prefs.setString('dateCreated', dateCreated.toIso8601String());
  }

  // Method to load details from shared preferences
  Future<void> loadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    aadharNumber = prefs.getString('aadharNumber');
    username = prefs.getString('username');
    dateCreated = prefs.getString('dateCreated') != null
        ? DateTime.parse(prefs.getString('dateCreated')!)
        : null;
  }

  // Method to check if Aadhar card details are available
  bool isAadharAvailable() {
    return aadharNumber != null && username != null && dateCreated != null;
  }

  // Method to get Aadhar card layout
  Widget getAadharCardLayout() {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/images/aadhar_dummy_svg.svg",
          height: 170.h,
          width: 270.w,
        ),
        Positioned(
          left: 40.w,
          top: 55.h,
          child: Row(
            children: [
              Text(
                formatAadhaar(aadharNumber!),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: formatAadhaar(aadharNumber!)));
                },
                child: Icon(
                  Icons.copy,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 30.h,
          left: 10.h,
          child: Text(
            "Issued Locally",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 18.h,
          left: 10.h,
          child: Text(
            formatter.format(dateCreated!),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
            right: 20.w,
            bottom: 30.h,
            child: Text(username!,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Positioned(
            bottom: 9,
            right: 15,
            child: Image.asset(
              "assets/PaperSafeLogos/paper_safe_gradient.png",
              height: 45,
              width: 70,
            ))
      ],
    );
  }

  String formatAadhaar(String input) {
    // Use a regular expression to insert a space after every 4 digits
    final RegExp regExp = RegExp(r".{1,4}");
    final Iterable<Match> matches = regExp.allMatches(input);

    // Join the matches with a space
    final String formatted = matches.map((match) => match.group(0)).join(' ');

    return formatted;
  }
}
