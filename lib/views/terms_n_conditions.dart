import 'package:_first_one/constants/strings_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terms and Conditions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 40,
                    color: Colors.black,
                  ),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                )
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getHeading(AppStrings.introduction),
                  minHeight(),
                  _getContent(AppStrings.introC),
                  maxHeight(),
                  _getHeading(AppStrings.eligibility),
                  minHeight(),
                  _getContent(AppStrings.eligibC),
                  maxHeight(),
                  _getHeading(AppStrings.accountReg),
                  minHeight(),
                  _getContent(AppStrings.accRegC),
                  minHeight(),
                  _getHeading(AppStrings.useOfServices),
                  minHeight(),
                  _getContent(AppStrings.userOfServicesContent),
                  minHeight(),
                  _getHeading(AppStrings.userResponsibilities),
                  minHeight(),
                  _getContent(AppStrings.userResponsibilitiesContent),
                  _getContent(AppStrings.responsibility1, FontWeight.w400, 15),
                  _getContent(AppStrings.responsibility2, FontWeight.w400, 15),
                  _getContent(AppStrings.responsibility3, FontWeight.w400, 15),
                  maxHeight(),
                  _getHeading(AppStrings.privacyPolicy),
                  minHeight(),
                  _getContent(AppStrings.privacyPolicyContent),
                  minHeight(),
                  _getHeading(AppStrings.dataSecuirity),
                  minHeight(),
                  _getContent(AppStrings.dataSecuirityContent),
                  maxHeight(),
                  _getHeading(AppStrings.dataSecuirity),
                  minHeight(),
                  _getContent(AppStrings.dataSecuirityContent),
                  maxHeight(),
                  _getHeading(AppStrings.prohibitedActivities),
                  minHeight(),
                  _getContent(AppStrings.prohibitedActivitiesContent),
                  _getContent(AppStrings.prohibition1, FontWeight.w400, 15),
                  _getContent(AppStrings.prohibition2, FontWeight.w400, 15),
                  _getContent(AppStrings.prohibition3, FontWeight.w400, 15),
                  minHeight(),
                  _getHeading(AppStrings.intellectualProperty),
                  minHeight(),
                  _getContent(AppStrings.intellectualPropertContent),
                  minHeight(),
                  _getHeading(AppStrings.termination),
                  minHeight(),
                  _getContent(AppStrings.terminationContent),
                  minHeight(),
                  _getHeading(AppStrings.contactUs),
                  minHeight(),
                  _getContent(AppStrings.contactUsContent),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text("mail to:"),
                          TextButton(
                              onPressed: () {
                                _launchEmail();
                              },
                              child: Text("mohit.kumar@gmail.com")),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Call:"),
                          TextButton(
                              onPressed: () {
                                _launchPhone();
                              },
                              child: Text("+91 879034508"))
                        ],
                      ),
                    ],
                  ),
                  maxHeight(),
                  Divider(
                    thickness: 1.5,
                    color: Colors.black,
                  ),
                  maxHeight(),
                  _getContent(AppStrings.conclusion, FontWeight.w400, 17),
                  maxHeight(),
                  maxHeight()
                ],
              )),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _getHeading(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _getContent(String content,
      [FontWeight ft = FontWeight.w500, double s = 16]) {
    return Text(
      content,
      style: TextStyle(fontSize: s, fontWeight: ft),
    );
  }

  Widget maxHeight() {
    return SizedBox(
      height: 10.h,
    );
  }

  Widget minHeight() {
    return SizedBox(
      height: 5.h,
    );
  }

  // Function to launch email client
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'mohit.kumar@gmail.com',
        queryParameters: {'subject': 'Support Request'});

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

// Function to launch phone dialer
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+91879034508',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }
}
