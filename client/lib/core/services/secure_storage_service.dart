import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:papersafe/models/user.dart';

/// Secure wrapper around FlutterSecureStorage.
/// Replaces SharedPreferences for sensitive data (user, token).
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyUser         = 'ps_user';
  static const _keyAccessToken  = 'ps_access_token';
  static const _keyRefreshToken = 'ps_refresh_token';

  // ─── User ─────────────────────────────────────────────────────────────────
  static Future<void> storeUser(User user) async {
    final json = jsonEncode(toJson(user));
    await _storage.write(key: _keyUser, value: json);
  }

  static Future<User?> retrieveUser() async {
    final json = await _storage.read(key: _keyUser);
    if (json == null) return null;
    return User.fromJson(jsonDecode(json));
  }

  static Future<void> removeUser() async {
    await _storage.delete(key: _keyUser);
  }

  // ─── Tokens ───────────────────────────────────────────────────────────────
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken,  value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  // ─── Clear all ────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ─── Auth check ───────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
