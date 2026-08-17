import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papersafe/core/services/biometric_service.dart';
import 'package:papersafe/core/services/secure_storage_service.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    state = await SecureStorageService.getBiometricEnabled();
  }

  Future<bool> toggleBiometrics(bool enabled) async {
    await SecureStorageService.setBiometricEnabled(enabled);
    state = enabled;
    return enabled;
  }
}

final biometricEnabledProvider =
    StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

/// Indicates whether the app is currently locked behind biometric security.
final isAppLockedProvider = StateProvider<bool>((ref) => false);
