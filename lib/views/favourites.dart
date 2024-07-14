import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/user.dart';
import 'package:_first_one/models/user_manager.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  StreamSubscription<User?>? _userSubscription;
  User? _currentUser;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  ApiService _apiService = ApiService();

  Uint8List? _AadhaarImage;
  Uint8List? _panImage;
  Uint8List? _xMarksheetImage;
  Uint8List? _xiiMarksheetImage;
  List<File>? _movieTickets;

  // Future<void> _fetchAndShowAadhaar() async {
  //   print(" Aadhaar for ${_currentUser!.id}");
  //   Uint8List? imageData =
  //       await _apiService.fetchImageData(_currentUser!.id!, "Aadhaar");
  //   if (imageData != null) {
  //     setState(() {
  //       _AadhaarImage = imageData;
  //     });
  //   } else {
  //     print("Failed to fetch aadhaar image data.");
  //   }
  // }

  // Future<void> _fetchAndShowPAN() async {
  //   print(" PAN for ${_currentUser!.id}");
  //   Uint8List? imageData =
  //       await _apiService.fetchImageData(_currentUser!.id!, "PAN");
  //   if (imageData != null) {
  //     setState(() {
  //       _panImage = imageData;
  //     });
  //   } else {
  //     print("Failed to fetch pan image data.");
  //   }
  // }

  // _updateDoucuments() async {
  //   DocumentManager().refreshDocuments();
  // }

  // Future<void> _fetchAndShowXmarksheet() async {
  //   print(" XmarkSheet for ${_currentUser!.id}");
  //   Uint8List? imageData =
  //       await _apiService.fetchImageData(_currentUser!.id!, "XMarkSheet");
  //   if (imageData != null) {
  //     setState(() {
  //       _xMarksheetImage = imageData;
  //     });
  //   } else {
  //     print("Failed to fetch xMarksheet data.");
  //   }
  // }

  @override
  void initState() {
    // _updateDoucuments();
    //  _AadhaarImage = DocumentManager().getDocument('Aadhaar');
    //  _panImage = DocumentManager().getDocument('PAN');
    super.initState();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(25.w, 25.h, 25.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
                "Favourites",
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
