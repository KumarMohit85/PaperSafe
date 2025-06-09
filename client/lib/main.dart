import 'package:_first_one/views/homepage.dart';
import 'package:_first_one/views/login_signup.dart';
import 'package:_first_one/models/aadhar_frame.dart';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/pan_frame.dart';
import 'package:_first_one/models/user_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserManager.instance.refreshUser(); // Load user details first
  AadharFrame aadharFrame = AadharFrame();
  await aadharFrame.loadDetails();

  PanFrame panFrame = PanFrame();
  await panFrame.loadDetails();
  DocumentManager()
      .initialize(); // Set up the document manager to listen for user changes
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
    ));

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          home: FutureBuilder<bool>(
            future: getIsLogin(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else {
                bool isLoggedIn = snapshot.data ?? false;
                return isLoggedIn ? HomePage() : LoginPage();
              }
            },
          ),
        );
      },
    );
  }

  Future<bool> getIsLogin() async {
    UserManager _userManager = UserManager();
    _userManager.refreshUser();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString("user"));
    if (prefs.getString("user") != null)
      return true;
    else
      return false;
  }
}
