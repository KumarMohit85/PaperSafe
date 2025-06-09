import 'dart:io';
import 'dart:typed_data';

import 'package:_first_one/views/homepage.dart';
import 'package:_first_one/models/user.dart';
import 'package:_first_one/models/user_manager.dart';
import 'package:_first_one/views/tell_more.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://papersafe.onrender.com',
            connectTimeout: Duration(milliseconds: 30000),
            receiveTimeout: Duration(milliseconds: 30000),
            sendTimeout: Duration(milliseconds: 30000),
          ),
        );

// requestForOtp
  Future<bool> postEmail(String email, BuildContext context) async {
    const String endPoint = '/api/v1/requestOTP'; // Corrected API URL

    try {
      // Set content type to x-www-form-urlencoded
      final response = await _dio.post(
        endPoint,
        data: {'emailID': email},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        print('Email posted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text("OTP sent succesfully")));
        print(response.data);
        return true;
      } else {
        print('Failed to post email: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to post email: ${response.statusCode}')));
        return false;
      }
    } catch (e) {
      print('Error occurred while posting email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred while posting email: $e")));
      return false;
    }
  }

//verify OTP
  Future<void> postOTP(String email, String otp, BuildContext context) async {
    const String endPoint = '/api/v1/verifyOTP'; // Corrected API URL

    try {
      // Set content type to x-www-form-urlencoded
      print("POST OTP CALLED");
      final response = await _dio.post(
        endPoint,
        data: {'otp': otp, 'emailID': email},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        print('OTP sent');
        print(response.data);
        bool doExist = response.data['data']['doExist'];
        if (doExist) {
          User user = User.fromJson(response.data['data']['user']);
          UserManager.instance.setUser(user);
          print("existing user successfully added to stream");
          print(toJson(user));

          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        } else {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return UserInformation(email: email);
          }));
        }
      } else {
        print('Failed to post otp: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while posting otp: $e');
    }
  }

//User SignUp
  Future<bool> postNewUser(String firstName, String lastName, String mobNo,
      String gender, String emailId, String dob, BuildContext context) async {
    try {
      final response = await _dio.post(
        '/api/v1/register', // Replace with your endpoint
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
        print('User successfully registered: ${response.data['data']}');
        final userData = response.data['data'];
        User user = User.fromJson(userData);

        UserManager.instance
            .setUser(user); // This will overwrite the existing user
        print("user successfully added to stream");
        print(toJson(user));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User successfully registered')));
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
        return true;
      } else {
        print('Failed to register user: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to register user: ${response.statusCode}')));
        print('Response data: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error occurred while posting user details: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        return false;
      } else {
        print('Error occurred while posting user details: ${e.message}');
        print('Request data: ${e.requestOptions.data}');
        return false;
      }
    } catch (e) {
      print('Unexpected error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred: $e')));
      return false;
    }
  }

//Update User details
  Future<void> updateUser(String userId, Map<String, dynamic> updatedData,
      BuildContext context) async {
    final String endPoint = "/api/v1/updateUser/$userId";

    try {
      final response = await _dio.patch(
        endPoint,
        data: updatedData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        print("User updated successfully");
        final userData = response.data['data'];
        User user = User.fromJson(userData);
        UserManager.instance
            .updateUser(user); // This will overwrite the existing user
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User updated succesfully')));
        print(user);
        // Handle successful response
      } else {
        print("Failed to update user: ${response.statusCode}");
        print("Response data: ${response.data}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error occurred while updating user details: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      } else {
        print('Error occurred while updating user details: ${e.message}');
        print('Request data: ${e.requestOptions.data}');
      }
    } catch (e) {
      print('Unexpected error occurred: $e');
    }
  }

//Delete User
  Future<void> deleteUser(String userId, BuildContext context) async {
    final String endPoint = "/api/v1/deleteUser/$userId";

    try {
      final response = await _dio.delete(
        endPoint,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        print("User deleted successfully");
        UserManager.instance.clearUser(); // Clear the user from UserManager
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User deleted successfully')));
        // Handle successful response
      } else {
        print("Failed to delete user: ${response.statusCode}");
        print("Response data: ${response.data}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Error occurred while deleting user: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      } else {
        print('Error occurred while deleting user: ${e.message}');
        print('Request data: ${e.requestOptions.data}');
      }
    } catch (e) {
      print('Unexpected error occurred: $e');
    }
  }

//uploadAadharCard
  Future<void> uploadAadhar(
    String userId,
    File imageFile,
    BuildContext context,
    String number,
  ) async {
    print("upload aadhaar request called from apiServices");
    String endPoint = "/api/v1/uploadAadhaar"; // Replace with your server URL
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'aadhaar': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'userID': userId,
      'aadhaarNumber': number,
    });

    try {
      Response response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Aadhar uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aadhar uploaded successfully')),
        );
      } else {
        print('Failed to upload Aadhar: ${response.statusCode}');
        print('Response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload Aadhar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading Aadhar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while uploading Aadhar: $e')),
      );
    }
  }

//upload PAN
  Future<void> uploadPan(
    String userId,
    File imageFile,
    BuildContext context,
    String number,
  ) async {
    print("upload pan request called from apiServices");
    String endPoint = "/api/v1/uploadPAN"; // Replace with your server URL
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'pan': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'userID': userId,
      'panNumber': number,
    });

    try {
      Response response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('PAN uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PAN uploaded successfully')),
        );
      } else {
        print('Failed to upload PAN: ${response.statusCode}');
        print('Response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload PAN: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading PAN: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while uploading PAN: $e')),
      );
    }
  }

//upload Xmarksheet
  Future<void> uploadXmarksheet(
    String userId,
    File imageFile,
    BuildContext context,
  ) async {
    print("upload xMarksheet request called from apiServices");
    String endPoint =
        "/api/v1/uploadXMarkSheet"; // Replace with your server URL
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'xMarkSheet': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'userID': userId,
    });

    try {
      Response response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('XMarksheet uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('XMarksheet uploaded successfully')),
        );
      } else {
        print('Failed to upload XMarksheet: ${response.statusCode}');
        print('Response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to upload XMarksheet: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading XMarksheet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error occurred while uploading XMarksheet: $e')),
      );
    }
  }

//upload XiiMarksheet
  Future<void> uploadXIImarksheet(
    String userId,
    File imageFile,
    BuildContext context,
  ) async {
    print("upload xii marksheet request called from apiServices");
    String endPoint =
        "/api/v1/uploadXIIMarkSheet"; // Replace with your server URL
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'xiiMarkSheet': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'userID': userId,
    });

    try {
      Response response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('XII Marksheet uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('XII Marksheet uploaded successfully')),
        );
      } else {
        print('Failed to upload XII Marksheet: ${response.statusCode}');
        print('Response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to upload XII Marksheet: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading XII Marksheet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error occurred while uploading XII Marksheet: $e')),
      );
    }
  }

//uploadMovieTicket
  Future<void> uploadMovieTicket(
    String userId,
    File imageFile,
    BuildContext context,
  ) async {
    print("upload movie_ticket request called from apiServices");
    String endPoint =
        "/api/v1/uploadMovieTicket"; // Replace with your server URL
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'movieTicket': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'userID': userId,
    });

    try {
      Response response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Movie ticket uploaded successfully: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Movie ticket uploaded successfully')),
        );
      } else {
        print('Failed to upload movie ticket: ${response.statusCode}');
        print('Response data: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to upload movie ticket: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while uploading movie ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error occurred while uploading movie ticket: $e')),
      );
    }
  }
  //uploadTrainTicket
  // Future<void> uploadTrainTicket(
  //     String userId, File imageFile, BuildContext context) async {
  //   print("upload train_ticket request called from apiServices");
  //   String endPoint =
  //       "/api/v1/upload"; // Replace with your server URL
  //   String fileName = imageFile.path.split('/').last;
  //   FormData formData = FormData.fromMap({
  //     'movieTicket': await MultipartFile.fromFile(
  //       imageFile.path,
  //       filename: fileName,
  //     ),
  //     'userID': userId,
  //   });
  //   try {
  //     Response response = await _dio.post(
  //       endPoint,
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           HttpHeaders.contentTypeHeader: 'multipart/form-data',
  //         },
  //       ),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print('Movie ticket uploaded successfully: ${response.data}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('movie ticket uploaded successfully')));
  //     } else {
  //       print('Failed to upload movie ticket : ${response.statusCode}');
  //       print('Response data: ${response.data}');
  //     }
  //   } catch (e) {
  //     print('Error occurred while uploading movie ticket : $e');
  //   }
  // }

  Future<Uint8List?> fetchImageData(String id, String card) async {
    print(" called image fetching request for ${card} of ${id}");
    final String endPoint =
        '/api/v1/download${card}/$id'; // Replace with your actual URL
    try {
      final response = await _dio.get(
        endPoint,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        print("succesfully downloaded ${card} for ${id}");
        return response.data;
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred while fetching ${card} data: $e");
      return null;
    }
  }

  Future<File?> downloadZipFile(String userId) async {
    String endPoint = "/api/v1/downloadMovieTicket/${userId}";
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final zipFilePath = '$tempPath/images.zip';

      final response = await _dio.get(
        endPoint,
        options: Options(responseType: ResponseType.bytes),
      );

      final zipFile = File(zipFilePath);
      await zipFile.writeAsBytes(response.data);
      return zipFile;
    } catch (e) {
      print('Error downloading zip file: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String id, String card) async {
    print("delete request called for $id for ${card}");
    final String endPoint =
        '/api/v1/delete${card}/$id'; // Replace with your actual URL

    try {
      final response = await _dio.delete(endPoint);

      if (response.statusCode == 200) {
        print("Image deleted successfully");
        return true;
      } else {
        print("Failed to delete image: ${response.statusCode}");
        print("Response data: ${response.data}");
        return false;
      }
    } catch (e) {
      print("Error occurred while deleting image: $e");
      return false;
    }
  }
}
