import 'package:_first_one/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CardType { pan, aadhaar }

class AddingFrame extends StatefulWidget {
  AddingFrame({super.key, required this.cardType, required this.user});
  CardType cardType;
  User user;
  @override
  State<AddingFrame> createState() => _AddingFrameState();
}

class _AddingFrameState extends State<AddingFrame> {
  TextEditingController _number = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              CupertinoIcons.back,
                              size: 40,
                            )),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          "Add ${_getCardType(widget.cardType)}",
                          style: TextStyle(
                              fontSize: 25.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Container(
                      height: 43.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(60.r)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 10.h),
                        child: TextField(
                          controller: _number,
                          style:
                              TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${_getCardType(widget.cardType)} Number",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ]))),
    );
  }

  String _getCardType(CardType cardType) {
    switch (cardType) {
      case CardType.aadhaar:
        return "Aadhaar";
      case CardType.pan:
        return "PAN";
      default:
        return "Default";
    }
  }
}
