import 'dart:async';
import 'package:_first_one/models/app_preferences.dart';
import 'package:_first_one/models/user.dart';

class UserManager {
  User? _user;
  final _userController = StreamController<User?>.broadcast();

  User? get user => _user;

  Stream<User?> get userStream => _userController.stream;

  static final UserManager instance = UserManager._internal();

  factory UserManager() {
    return instance;
  }

  UserManager._internal();

  void setUser(User user) async {
    print("set user called from user manager");
    print(user.firstName);
    AppPreferences appPreferences = AppPreferences();
    await appPreferences.storeUser(user);
    refreshUser();
  }

  void updateUser(User updatedUser) async {
    AppPreferences appPreferences = AppPreferences();
    await appPreferences.storeUser(updatedUser);
    _user = updatedUser;
    _userController.sink.add(updatedUser);
  }

  void clearUser() async {
    AppPreferences appPreferences = AppPreferences();
    await appPreferences.removeUser();
    print("clear user called");
    refreshUser();
  }

  Future<void> refreshUser() async {
    print("refresh user called");
    AppPreferences appPreferences = AppPreferences();
    Map<String, dynamic>? userJson = await appPreferences.retreiveUser();
    if (userJson == null) {
      print("user is null from shared preferences");
      _user = null;
      _userController.sink.add(null);
    } else {
      User user = User.fromJson(userJson);
      print(user.firstName);
      _user = user;
      _userController.sink.add(user);
    }
  }

  Future<User?> getUser() async {
    print("get user called");
    await refreshUser();
    if (_user != null) {
      print(_user!.firstName);
      return _user!;
    } else
      return null;
  }

  void dispose() {
    _userController.close();
  }
}
