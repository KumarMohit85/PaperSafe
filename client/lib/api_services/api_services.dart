import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/core/services/secure_storage_service.dart';
import 'package:papersafe/models/documents_manager.dart';

class ApiService {
  static const String _baseUrl = 'https://papersafe.onrender.com';
  static const bool useMockBackend = true;

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        sendTimeout:    const Duration(milliseconds: 30000),
      ),
    );

    // ── Request interceptor: attach JWT to every protected call ──────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // 401 → try refresh once
          if (error.response?.statusCode == 401) {
            final refreshToken = await SecureStorageService.getRefreshToken();
            if (refreshToken != null) {
              try {
                final response = await Dio().post(
                  '$_baseUrl/api/v1/refreshToken',
                  data: {'refreshToken': refreshToken},
                  options: Options(
                    contentType: Headers.formUrlEncodedContentType,
                  ),
                );
                final newAccessToken  = response.data['data']['accessToken']  as String;
                final newRefreshToken = response.data['data']['refreshToken'] as String;
                await SecureStorageService.storeTokens(
                  accessToken:  newAccessToken,
                  refreshToken: newRefreshToken,
                );
                // Retry original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                // Refresh failed – force logout (caller handles it)
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  /// Request OTP for given email
  Future<bool> postEmail(String email, BuildContext context) async {
    if (useMockBackend) {
      _showSnack(context, 'OTP sent successfully (Mock) ✅');
      return true;
    }
    try {
      final response = await _dio.post(
        '/api/v1/requestOTP',
        data: {'emailID': email},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200) {
        _showSnack(context, 'OTP sent successfully ✅');
        return true;
      }
      return false;
    } catch (e) {
      _showSnack(context, 'Failed to send OTP: $e', isError: true);
      return false;
    }
  }

  /// Verify OTP – returns response data map on success, null on failure
  Future<Map<String, dynamic>?> postOTP(
    String email,
    String otp,
    BuildContext context,
  ) async {
    if (useMockBackend) {
      final isNewUser = email.toLowerCase() == 'new@example.com';
      return {
        'doExist': !isNewUser,
        'accessToken': 'mock_access_token',
        'refreshToken': 'mock_refresh_token',
        'user': {
          '_id': 'mock_user_123',
          'schemaVersion': 1,
          'firstName': 'John',
          'lastName': 'Doe',
          'mobileNumber': 9876543210,
          'emailID': email,
          'dob': '1995-06-15T00:00:00.000Z',
          'gender': 'Male',
          'uniqueID': 'MOCK-UID-9999',
        }
      };
    }
    try {
      final response = await _dio.post(
        '/api/v1/verifyOTP',
        data: {'otp': otp, 'emailID': email},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _showSnack(context, 'OTP verification failed: $e', isError: true);
      return null;
    }
  }

  /// Register a new user – returns User on success, null on failure
  Future<Map<String, dynamic>?> postNewUser({
    required String firstName,
    required String lastName,
    required String mobNo,
    required String gender,
    required String emailId,
    required String dob,
    required BuildContext context,
  }) async {
    if (useMockBackend) {
      _showSnack(context, 'Welcome to PaperSafe! (Mock) 🎉');
      return {
        'doExist': true,
        'accessToken': 'mock_access_token',
        'refreshToken': 'mock_refresh_token',
        'user': {
          '_id': 'mock_user_123',
          'schemaVersion': 1,
          'firstName': firstName,
          'lastName': lastName,
          'mobileNumber': int.tryParse(mobNo) ?? 9876543210,
          'emailID': emailId,
          'dob': dob,
          'gender': gender,
          'uniqueID': 'MOCK-UID-9999',
        }
      };
    }
    try {
      final response = await _dio.post(
        '/api/v1/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'mobileNumber': mobNo,
          'emailID': emailId,
          'dob': dob,
          'gender': gender,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(context, 'Welcome to PaperSafe! 🎉');
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      _showSnack(
        context,
        'Registration failed: ${e.response?.data ?? e.message}',
        isError: true,
      );
      return null;
    }
  }

  /// Update user info (requires JWT)
  Future<User?> updateUser(
    String userId,
    Map<String, dynamic> updatedData,
    BuildContext context,
  ) async {
    if (useMockBackend) {
      _showSnack(context, 'Profile updated successfully (Mock)');
      return User.fromJson({
        '_id': userId,
        'schemaVersion': 1,
        'firstName': updatedData['firstName'] ?? 'John',
        'lastName': updatedData['lastName'] ?? 'Doe',
        'mobileNumber': int.tryParse(updatedData['mobileNumber']?.toString() ?? '') ?? 9876543210,
        'emailID': updatedData['emailID'] ?? 'demo@example.com',
        'dob': updatedData['dob'] ?? '1995-06-15T00:00:00.000Z',
        'gender': updatedData['gender'] ?? 'Male',
        'uniqueID': 'MOCK-UID-9999',
      });
    }
    try {
      final response = await _dio.patch(
        '/api/v1/updateUser/$userId',
        data: updatedData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200) {
        _showSnack(context, 'Profile updated successfully');
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _showSnack(context, 'Update failed: $e', isError: true);
      return null;
    }
  }

  /// Delete user (requires JWT)
  Future<bool> deleteUser(String userId, BuildContext context) async {
    if (useMockBackend) {
      _showSnack(context, 'Account deleted (Mock)');
      return true;
    }
    try {
      final response = await _dio.delete('/api/v1/deleteUser/$userId');
      if (response.statusCode == 200) {
        _showSnack(context, 'Account deleted');
        return true;
      }
      return false;
    } catch (e) {
      _showSnack(context, 'Delete failed: $e', isError: true);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOCUMENTS – UPLOAD
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> uploadAadhar(
    String userId, File imageFile, String number, BuildContext context,
  ) async =>
      _uploadSingleFile(
        endpoint: '/api/v1/uploadAadhaar',
        fieldName: 'aadhaar',
        file: imageFile,
        extras: {'userID': userId, 'aadhaarNumber': number},
        context: context,
        successMsg: 'Aadhaar uploaded',
      );

  Future<bool> uploadPan(
    String userId, File imageFile, String number, BuildContext context,
  ) async =>
      _uploadSingleFile(
        endpoint: '/api/v1/uploadPAN',
        fieldName: 'pan',
        file: imageFile,
        extras: {'userID': userId, 'panNumber': number},
        context: context,
        successMsg: 'PAN uploaded',
      );

  Future<bool> uploadXmarksheet(
    String userId, File imageFile, BuildContext context,
  ) async =>
      _uploadSingleFile(
        endpoint: '/api/v1/uploadXMarkSheet',
        fieldName: 'xMarkSheet',
        file: imageFile,
        extras: {'userID': userId},
        context: context,
        successMsg: 'X Marksheet uploaded',
      );

  Future<bool> uploadXIImarksheet(
    String userId, File imageFile, BuildContext context,
  ) async =>
      _uploadSingleFile(
        endpoint: '/api/v1/uploadXIIMarkSheet',
        fieldName: 'xiiMarkSheet',
        file: imageFile,
        extras: {'userID': userId},
        context: context,
        successMsg: 'XII Marksheet uploaded',
      );

  Future<bool> uploadMovieTicket(
    String userId, File imageFile, BuildContext context,
  ) async =>
      _uploadSingleFile(
        endpoint: '/api/v1/uploadMovieTicket',
        fieldName: 'movieTicket',
        file: imageFile,
        extras: {'userID': userId},
        context: context,
        successMsg: 'Movie ticket uploaded',
      );

  String? _endpointToDoctype(String endpoint) {
    if (endpoint.contains('uploadAadhaar')) return 'aadhaar';
    if (endpoint.contains('uploadPAN')) return 'pan';
    if (endpoint.contains('uploadXIIMarkSheet')) return 'xiiMarkSheet';
    if (endpoint.contains('uploadXMarkSheet')) return 'xMarkSheet';
    return null;
  }

  Future<bool> _uploadSingleFile({
    required String endpoint,
    required String fieldName,
    required File file,
    required Map<String, String> extras,
    required BuildContext context,
    required String successMsg,
  }) async {
    if (useMockBackend) {
      _showSnack(context, '$successMsg (Mock)');
      try {
        if (endpoint.contains('uploadMovieTicket')) {
          await DocumentManager().persistMockUpload('movieTicket', file);
        } else {
          final docType = _endpointToDoctype(endpoint);
          if (docType != null) {
            await DocumentManager().persistMockUpload(docType, file);
          }
        }
      } catch (e) {
        debugPrint('Local mock upload save error: $e');
      }
      return true;
    }
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
        ...extras,
      });
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: 'multipart/form-data'},
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(context, successMsg);
        return true;
      }
      return false;
    } catch (e) {
      _showSnack(context, 'Upload failed: $e', isError: true);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOCUMENTS – DOWNLOAD
  // ─────────────────────────────────────────────────────────────────────────

  /// Downloads an image document as bytes.
  /// [card] is one of: Aadhaar, PAN, XIIMarkSheet, XMarkSheet
  Future<Uint8List?> fetchImageData(String userId, String card) async {
    if (useMockBackend) {
      return null; // Local assets loaded via DocumentManager directly
    }
    try {
      final response = await _dio.get(
        '/api/v1/download$card/$userId',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return response.data as Uint8List;
      }
      return null;
    } catch (e) {
      debugPrint('fetchImageData error ($card): $e');
      return null;
    }
  }

  /// Downloads a zip of movie tickets, saves to temp dir, returns File.
  Future<File?> downloadMovieTicketZip(String userId) async {
    if (useMockBackend) {
      return null;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final zipPath = '${tempDir.path}/tickets_$userId.zip';
      final response = await _dio.get(
        '/api/v1/downloadMovieTicket/$userId',
        options: Options(responseType: ResponseType.bytes),
      );
      final file = File(zipPath);
      await file.writeAsBytes(response.data as List<int>);
      return file;
    } catch (e) {
      debugPrint('downloadMovieTicketZip error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOCUMENTS – DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> deleteImage(String userId, String card) async {
    if (useMockBackend) {
      await DocumentManager().deleteMockPersist(card);
      return true;
    }
    try {
      final response = await _dio.delete('/api/v1/delete$card/$userId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('deleteImage error ($card): $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  void _showSnack(
    BuildContext context,
    String msg, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }
}
