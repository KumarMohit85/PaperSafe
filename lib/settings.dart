import 'package:_first_one/delete_documents.dart';
import 'package:_first_one/terms_n_conditions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
                "Settings",
                style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.h,
              ),
              _getSubHeading("App Preferences"),
              _listButton("Secuirity", FontWeight.w400),
              InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ManageDocuments(title: "Delete Documents");
                    }));
                  },
                  child: _listButton("Delete Documents", FontWeight.w400)),
              _getDivider(),
              _getSubHeading("Need Help?"),
              _listButton("FAQs", FontWeight.w400),
              _listButton("Chat With Us", FontWeight.w400),
              _getDivider(),
              _listButton("Privacy policy", FontWeight.w600),
              _getDivider(),
              InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TermsAndConditions();
                    }));
                  },
                  child: _listButton("Terms & Conditions", FontWeight.w600)),
              Padding(
                padding: EdgeInsets.only(top: 20.h, right: 0, bottom: 0),
                child: Center(
                  child: Container(
                      height: 100.h,
                      width: 105.w,
                      // color: Colors.purple[400],
                      child: Image.asset(
                        "assets/PaperSafeLogos/dark_outline_logo.png",
                        //color: Colors.purple,
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h, right: 0, bottom: 0),
                child: Center(
                    child: Text(
                  "Thank you for using PaperSafe",
                  style: TextStyle(color: Color.fromARGB(255, 99, 98, 98)),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSubHeading(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, right: 0, bottom: 0),
      child: Text(
        text,
        style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _listButton(String text, FontWeight fontWeight) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, right: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 23.sp, fontWeight: fontWeight),
          ),
          Icon(CupertinoIcons.chevron_forward),
        ],
      ),
    );
  }

  Widget _getDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, right: 0, bottom: 0),
      child: Divider(
        thickness: 2.sp,
        color: Color(0xFF580F66),
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: TermsAndConditions(),
            );
          },
        );
      },
    );
  }
}
