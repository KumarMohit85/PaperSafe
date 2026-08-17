import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Service wrapping [LocalAuthentication] plugin for biometric hardware check,
/// available biometric types query, and authentication prompt.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if hardware supports biometrics or device PIN/passcode.
  Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error checking biometrics capability: $e');
      }
      return false;
    }
  }

  /// Get list of available biometric sensors (fingerprint, face, iris).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error getting available biometrics: $e');
      }
      return [];
    }
  }

  /// Trigger biometric authentication prompt with fallback to device credentials (PIN/Pattern).
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to unlock PaperSafe',
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Authentication exception: ${e.code} - ${e.message}');
      }
      if (e.code == auth_error.notEnrolled || e.code == auth_error.notAvailable) {
        // Device biometrics not configured
        return false;
      }
      return false;
    }
  }

  /// Stop authentication if prompt is currently active.
  Future<void> cancelAuthentication() async {
    await _auth.stopAuthentication();
  }
}
