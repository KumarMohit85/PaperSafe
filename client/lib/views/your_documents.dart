import 'dart:async';
import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/constants/colorManager.dart';
import 'package:_first_one/Widgets/document_button.dart';
import 'package:_first_one/Widgets/document_selector.dart';
import 'package:_first_one/views/login_signup.dart';
import 'package:_first_one/models/aadhar_frame.dart';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:_first_one/models/pan_frame.dart';
import 'package:_first_one/models/user.dart';
import 'package:_first_one/models/user_manager.dart';
import 'package:_first_one/Widgets/share_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CardType { pan, aadhaar }

class YourDocuments extends StatefulWidget {
  const YourDocuments({super.key});

  @override
  State<YourDocuments> createState() => _YourDocumentsState();
}

class _YourDocumentsState extends State<YourDocuments> {
  // List<ImageModel?> list = DocumentManager().allImages;
  User? _currentUser;

  final ApiService _apiService = ApiService();
  String? dropdownValue;
  bool _enableEditing = false;
  DateTime? selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Gender _selectedGender;
  late TextEditingController _date;
  late TextEditingController _month;
  late TextEditingController _year;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileNoController;
  late TextEditingController _emailController;
  void updateUser() async {
    _currentUser = await UserManager().getUser();

    if (_currentUser != null) {
      setState(() {
        _selectedGender = _currentUser!.gender;
        _firstNameController.text = _currentUser!.firstName;
        _lastNameController.text = _currentUser!.lastName;
        _mobileNoController.text = _currentUser!.mobileNumber.toString();
        _emailController.text = _currentUser!.emailId;
        _date.text = _currentUser!.dob.day.toString();
        _month.text = _currentUser!.dob.month.toString();
        _year.text = _currentUser!.dob.year.toString();
      });
    }

    _getDrawer();
  }

  Future<void> selectDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
        _date.text = selected.day.toString();
        _month.text = selected.month.toString();
        _year.text = selected.year.toString();
      });
    }
  }

  @override
  void initState() {
    _selectedGender = Gender.male;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _mobileNoController = TextEditingController();
    _emailController = TextEditingController();
    _date = TextEditingController(text: DateTime.now().day.toString());
    _month = TextEditingController(text: DateTime.now().month.toString());
    _year = TextEditingController(text: DateTime.now().year.toString());
    updateUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _getDrawer(),
      endDrawer: _getEndDrawer(DocumentManager().allImages),
      body: _getYourDocuments(),
    );
  }

  //your documents section
  Widget _getDrawer() {
    return Drawer(
      width: 255.w,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.w, 5.h, 5.w, 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.back,
                      weight: 10,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Your Profile",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 30.w),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.purple[100],
                      size: 70,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 25.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _enableEditing = !_enableEditing;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                height: 35.h,
                width: 200.h,
                decoration: BoxDecoration(
                  color: _enableEditing ? Colors.grey[200] : Colors.grey[350],
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 8.h),
                  child: TextField(
                    enabled: _enableEditing,
                    controller: _firstNameController,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: _enableEditing
                          ? Colors.deepPurple[700]
                          : Colors.grey[700],
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("First Name"),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 35.h,
                width: 200.h,
                decoration: BoxDecoration(
                  color: _enableEditing ? Colors.grey[200] : Colors.grey[350],
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 8.h),
                  child: TextField(
                    enabled: _enableEditing,
                    controller: _lastNameController,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: _enableEditing
                          ? Colors.deepPurple[700]
                          : Colors.grey[700],
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Last Name"),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 35.h,
                width: 200.h,
                decoration: BoxDecoration(
                  color: _enableEditing ? Colors.grey[200] : Colors.grey[350],
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 8.h),
                  child: TextField(
                    enabled: _enableEditing,
                    controller: _mobileNoController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: _enableEditing
                          ? Colors.deepPurple[700]
                          : Colors.grey[700],
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Your Phone No"),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 35.h,
                width: 200.h,
                decoration: BoxDecoration(
                  color: _enableEditing ? Colors.grey[200] : Colors.grey[350],
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
                  child: TextField(
                    enabled: _enableEditing,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _enableEditing
                          ? Colors.deepPurple[700]
                          : Colors.grey[700],
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Your Email address"),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 35.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color:
                          _enableEditing ? Colors.grey[200] : Colors.grey[350],
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      child: TextField(
                        enabled: _enableEditing,
                        controller: _date,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: _enableEditing
                              ? Colors.deepPurple[700]
                              : Colors.grey[700],
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Day",
                          hintStyle: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 35.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color:
                          _enableEditing ? Colors.grey[200] : Colors.grey[350],
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      child: TextField(
                        enabled: _enableEditing,
                        controller: _month,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: _enableEditing
                              ? Colors.deepPurple[700]
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Month",
                          hintStyle: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 35.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color:
                          _enableEditing ? Colors.grey[200] : Colors.grey[350],
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        child: TextField(
                          enabled: _enableEditing,
                          controller: _year,
                          style: TextStyle(
                            color: _enableEditing
                                ? Colors.deepPurple[700]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Year",
                            hintStyle: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _enableEditing ? selectDate : null,
                    icon: Icon(
                      Icons.calendar_month,
                      size: 30.sp,
                      color: _enableEditing
                          ? const Color.fromARGB(255, 169, 15, 230)
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Your Date of Birth"),
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Gender.values.map((Gender gender) {
                  return InkWell(
                    onTap: _enableEditing
                        ? () {
                            setState(() {
                              _selectedGender = gender;
                            });
                          }
                        : null,
                    child: Container(
                      height: 30.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                          border: _selectedGender == gender
                              ? Border.all(
                                  color: _enableEditing
                                      ? Colors.deepPurple
                                      : Colors.grey[700]!,
                                  width: 2)
                              : Border.all(width: 0),
                          borderRadius: BorderRadius.circular(60.r)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 29.h,
                          width: 59.w,
                          decoration: BoxDecoration(
                              color: _selectedGender == gender
                                  ? _enableEditing
                                      ? const Color.fromARGB(255, 219, 102, 239)
                                      : Colors.grey
                                  : Colors.grey[200],
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
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () async {
                    // print(_selectedGender);
                    await _apiService.updateUser(
                        _currentUser!.id!,
                        {
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'mobileNumber': _mobileNoController.text,
                          'emailID': _emailController.text,
                          'dob': selectedDate!.toIso8601String(),
                          'gender': genderToString(_selectedGender)
                        },
                        context);

                    updateUser();
                    setState(() {
                      _enableEditing = false;
                    });
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.deepPurple),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Center(
                child: InkWell(
                  onTap: () {
                    UserManager userManager = UserManager();
                    userManager.clearUser();
                    // updateUser();
                    _restartApp(context);
                    // print(toJson(_currentUser!));
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    await _apiService.deleteUser(_currentUser!.id!, context);
                    // ignore: use_build_context_synchronously
                    _restartApp(context);
                  },
                  child: Text(
                    "Delete Account",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartApp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _getAadharCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4),
      child: AadharFrame().isAadharAvailable()
          ? AadharFrame().getAadharCardLayout()
          : Card(
              child: SizedBox(
                height: 200.h,
                width: 340.w,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      InkWell(
                        onTap: () {
                          if (_currentUser != null) {
                            addFrame(CardType.aadhaar);
                          }
                        },
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 50.sp,
                          color: ColorManager().primary,
                        ),
                      ),
                      Text(
                        "No aadhar card available click to add",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _getPanCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4),
      child: PanFrame().isPanAvailable()
          ? PanFrame().getPanCardLayout()
          : Card(
              child: SizedBox(
                height: 200.h,
                width: 340.w,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      InkWell(
                        onTap: () {
                          if (_currentUser != null) {
                            addFrame(CardType.pan);
                          }
                        },
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 50.sp,
                          color: ColorManager().primary,
                        ),
                      ),
                      Text(
                        "No pan card available click to add",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _getAd(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        height: 100.h,
        width: 270.h,
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  //body for yourDocuments
  Widget _getYourDocuments() {
    return Container(
        margin: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 20.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: Icon(
                  Icons.account_circle,
                  color: Colors.grey[700],
                  size: 40.sp,
                ),
              ),
              ShareButton(scaffoldKey: _scaffoldKey)
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "Your Documents",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Cards",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    CarouselSlider(
                      items: [
                        _getAadharCard(),
                        _getPanCard(),
                        _getAadharCard(),
                        _getPanCard(),
                      ],
                      options: CarouselOptions(
                        height: 180.h,
                        autoPlay: false,
                        viewportFraction: 0.8.sp,
                        pauseAutoPlayOnTouch: true,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    CarouselSlider(
                      items: [_getAd("ad1"), _getAd("ad2")],
                      options: CarouselOptions(
                        height: 100.h,
                        autoPlay: true,
                        autoPlayInterval: const Duration(milliseconds: 2000),
                        viewportFraction: 1.sp,
                        pauseAutoPlayOnTouch: true,
                      ),
                    ),
                    // _currentUser != null
                    //     ? Container(
                    //         child: Column(
                    //           children: [
                    //             Text('ID: ${_currentUser!.id}'),
                    //             Text(
                    //                 'Schema Version: ${_currentUser!.schemaVersion}'),
                    //             Text('First Name: ${_currentUser!.firstName}'),
                    //             Text('Last Name: ${_currentUser!.lastName}'),
                    //             Text(
                    //                 'Mobile Number: ${_currentUser!.mobileNumber}'),
                    //             Text('Email ID: ${_currentUser!.emailId}'),
                    //             Text(
                    //                 'Date of Birth: ${_currentUser!.dob.toIso8601String()}'),
                    //             Text(
                    //                 'Gender: ${_currentUser!.gender.toString().split('.').last}'),
                    //           ],
                    //         ),
                    //       )
                    //     : Text("No user data available"),
                    SizedBox(
                      height: 6.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              _askFrame();
                            },
                            child: _getCustomSquare(
                                Icons.add_card, "Add/Edit cards"),
                          ),
                          InkWell(
                            onTap: () {},
                            child:
                                _getCustomSquare(Icons.folder, "Add Document"),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6.h,
                    ),
                    DocumentButton()
                  ]),
            ),
          ),
        ]));
  }

  void addFrame(CardType cardType) {
    TextEditingController number = TextEditingController();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: SizedBox(
            height: 500,
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                ),
                Container(
                  height: 43.h,
                  width: 300.h,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(60.r)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    child: TextField(
                      controller: number,
                      style: TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${getCardType(cardType)} Number",
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                ElevatedButton(
                    onPressed: () {
                      setDetails(cardType, number.text);
                    },
                    child: Text("save ${getCardType(cardType)} details"))
              ],
            ),
          ));
        });
  }

  String getCardType(CardType cardType) {
    switch (cardType) {
      case CardType.pan:
        return "PAN";

      case CardType.aadhaar:
        return "Aadhaar";
    }
  }

  void setDetails(CardType cardType, String number) {
    switch (cardType) {
      case CardType.pan:
        PanFrame().setDetails(
            number,
            "${_currentUser!.firstName} ${_currentUser!.lastName}",
            DateTime.now());
      case CardType.aadhaar:
        AadharFrame().setDetails(number,
            _currentUser!.firstName + _currentUser!.lastName, DateTime.now());
    }
    setState(() {
      _getAadharCard();
      _getPanCard();
    });
    Navigator.of(context).pop();
  }

  Widget _getEndDrawer(List<ImageModel?> list) {
    return Drawer(
        width: 235.w,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.fromLTRB(15.w, 5.h, 5.w, 5.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(
                                CupertinoIcons.back,
                                weight: 10,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              "Share",
                              style: TextStyle(
                                  fontSize: 30.sp, fontWeight: FontWeight.w500),
                            )
                          ]),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        "Select Documents to Share",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      DocumentSelector()
                    ]))));
  }

  _getCustomSquare(IconData icon, String text) {
    return Container(
      height: 120.h,
      width: 120.h,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 227, 130, 244),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
            width: 2.5.sp, color: const Color.fromARGB(255, 113, 8, 122)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Icon(
              icon,
              size: 60,
              color: ColorManager().primary,
            )),
            Text(
              text,
              style: TextStyle(
                  height: 0.9.h, fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _askFrame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 100.h,
          child: AlertDialog(
            title: const Text(
              'Select Card you want to add',
              style: TextStyle(fontSize: 16),
            ),
            content: SizedBox(
              height: 70.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      addFrame(CardType.aadhaar);
                    },
                    child: _getCustomButton2(
                        "assets/images/aadhar_logo.png", "Aadhar"),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      addFrame(CardType.pan);
                    },
                    child: _getCustomButton2(
                        "assets/images/id_card_logo.png", "PAN"),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: ColorManager().primary),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.all(8.0),
          ),
        );
      },
    );
  }

  Widget _getCustomButton2(String image, String text) {
    return Container(
      height: 30.h,
      width: 85.w,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 227, 130, 244),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
              width: 2.5.sp, color: const Color.fromARGB(255, 113, 8, 122))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.h, vertical: 4.h),
        child: Row(
          children: [
            Image.asset(
              image,
              height: 13.h,
              width: 20.h,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 30.w,
            ),
          ],
        ),
      ),
    );
  }
}
