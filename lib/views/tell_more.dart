import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/views/homepage.dart';
import 'package:_first_one/models/user.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class UserInformation extends StatefulWidget {
  UserInformation({super.key, required this.email});
  String email;
  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  Gender _selectedGender = Gender.male;
  bool _isLoading = false;
  DateTime? selectedDate = DateTime.now();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _mobileNo = TextEditingController();
  TextEditingController _date =
      TextEditingController(text: DateTime.now().day.toString());
  TextEditingController _month =
      TextEditingController(text: DateTime.now().month.toString());
  TextEditingController _year =
      TextEditingController(text: DateTime.now().year.toString());

  Future<void> selectDate() async {
    DateTime? _selected = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(DateTime.now().year + 1),
        initialDate: DateTime.now());
    if (_selected != null) {
      setState(() {
        selectedDate = _selected;
        _date.text = _selected.day.toString();
        _month.text = _selected.month.toString();
        _year.text = _selected.year.toString();
      });
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobileNo.dispose();
    _date.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 0),
            color: Colors.white,
            child: Column(children: [
              Text(
                "Tell Us More about you",
                style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w700,
                    height: 0.9.h),
                softWrap: true,
              ),
              SizedBox(
                height: 35.h,
              ),
              Container(
                height: 43.h,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(60.r)),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: TextField(
                    controller: _firstName,
                    style: TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "First Name",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                height: 43.h,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(60.r)),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: TextField(
                    controller: _lastName,
                    style: TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Last Name",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                height: 43.h,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(60.r)),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: TextField(
                    controller: _mobileNo,
                    style: TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Mobile Number",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 43.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(60.r)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 12.h),
                        child: TextField(
                          controller: _date,
                          style:
                              TextStyle(fontSize: 16.sp, letterSpacing: 1.5.w),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Date",
                              hintStyle: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 43.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(60.r)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 12.h),
                        child: TextField(
                          controller: _month,
                          style:
                              TextStyle(fontSize: 16.sp, letterSpacing: 1.5.w),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Month",
                              hintStyle: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 43.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(60.r)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 12.h),
                        child: TextField(
                          controller: _year,
                          style:
                              TextStyle(fontSize: 16.sp, letterSpacing: 1.5.w),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Year",
                              hintStyle: TextStyle(fontSize: 16.sp)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        selectDate();
                      },
                      icon: Icon(
                        Icons.calendar_month,
                        size: 30.sp,
                        color: Colors.purple,
                      ))
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Your Date of Birth",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: Gender.values.map((Gender gender) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                    child: Container(
                      height: 46.h,
                      width: 93.w,
                      decoration: BoxDecoration(
                          border: _selectedGender == gender
                              ? Border.all(color: Colors.deepPurple, width: 2)
                              : Border.all(width: 0),
                          borderRadius: BorderRadius.circular(60.r)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 45.5.h,
                          width: 92.5.w,
                          decoration: BoxDecoration(
                              color: _selectedGender == gender
                                  ? Color.fromARGB(255, 219, 102, 239)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(60.r)),
                          child: Center(
                            child: Text(
                              gender.toString().split('.').last,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Gender",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                height: 10.h,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isLoading = true;
                  });
                  ApiService _apiService = ApiService();

                  _apiService.postNewUser(
                    _firstName.text,
                    _lastName.text,
                    _mobileNo.text,
                    genderToString(_selectedGender),
                    widget.email,
                    selectedDate!.toIso8601String(),
                    context,
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(38.r),
                  ),
                  child: Container(
                    height: 50.h,
                    width: 150.w,
                    alignment: Alignment.center,
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              _isLoading ? CircularProgressIndicator() : Container(),
            ]),
          ),
        ));
  }
}
