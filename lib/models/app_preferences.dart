import 'dart:convert';

import 'package:_first_one/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  void setUser(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogin", true);
  }

  Future<bool> getIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  Future<void> storeUser(User user) async {
    print("store user called from shared preferences");
    print(user.firstName);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(toJson(user));
    prefs.setString("user", userData);
  }

  Future<Map<String, dynamic>?> retreiveUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userJson = prefs.getString("user");
    if (userJson != null && userJson.isNotEmpty) {
      print("retrieve user called from shared preferences");
      print(jsonDecode(userJson));
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
  }
}
