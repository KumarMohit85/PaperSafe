import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/core/services/secure_storage_service.dart';

/// Holds the currently authenticated user (null when logged out).
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return await SecureStorageService.retrieveUser();
  }

  /// Called after OTP verification – stores user + tokens.
  Future<void> login({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await SecureStorageService.storeUser(user);
    await SecureStorageService.storeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    state = AsyncData(user);
  }

  /// Updates user profile data (after updateUser API call).
  Future<void> updateUser(User updatedUser) async {
    await SecureStorageService.storeUser(updatedUser);
    state = AsyncData(updatedUser);
  }

  /// Logs the user out and clears all stored data.
  Future<void> logout() async {
    await SecureStorageService.clearAll();
    state = const AsyncData(null);
  }

  /// Returns true if the user is currently authenticated.
  bool get isAuthenticated => state.valueOrNull != null;
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

/// Convenience provider: just the current user or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});
