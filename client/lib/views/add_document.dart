import 'dart:io';

import 'package:papersafe/views/add_documents.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

enum markSheetType { XMarkSheet, XIIMarkSheet }

class AddDocument extends StatefulWidget {
  const AddDocument({super.key, required this.docType, required this.id});
  final String id;
  final documentType docType;

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  final ApiService _apiService = ApiService();
  markSheetType _markTpe = markSheetType.XMarkSheet;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _number = TextEditingController();
  File? _image;
  bool _uploading = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF0F0C20), Color(0xFF15102A), Color(0xFF0D0D14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF5F4FF), Color(0xFFEAEAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D14) : const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Add ${getStringFromDoctype(widget.docType)}",
          style: TextStyle(
            fontSize: 20.sp, 
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E1E40),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getRightWidget(widget.docType),
                SizedBox(height: 30.h),
                
                // Image Preview Frame
                Center(
                  child: _image != null
                      ? Container(
                          width: 260.w,
                          height: 200.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 260.w,
                          height: 200.h,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48.r,
                                color: isDark ? Colors.white30 : Colors.black38,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No image selected',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? Colors.white30 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: 40.h),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _askSource(widget.docType),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text("Select Image"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          side: BorderSide(
                            color: isDark ? Colors.white30 : Colors.grey.shade400,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _uploading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: _image == null ? null : _uploadAndExit,
                              icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                              label: const Text("Upload", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C5CFC),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAndExit() async {
    setState(() => _uploading = true);
    try {
      if (widget.docType == documentType.XMarkSheet) {
        if (_markTpe == markSheetType.XMarkSheet) {
          await _uploadDocument(_image!, widget.docType, widget.id, _number.text);
        } else {
          await _uploadDocument(_image!, documentType.XIIMarkSheet, widget.id, _number.text);
        }
      } else {
        await _uploadDocument(_image!, widget.docType, widget.id, _number.text);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _askSource(documentType doc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Image Source",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: isDark ? Colors.white70 : Colors.black87),
                  title: Text("Camera", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFile(ImageSource.camera, doc, widget.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_outlined, color: isDark ? Colors.white70 : Colors.black87),
                  title: Text("Gallery", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFile(ImageSource.gallery, doc, widget.id);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImageFile(ImageSource source, documentType doc, String userId) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadDocument(File imageFile, documentType doc, String userId, String number) async {
    switch (doc) {
      case documentType.Aadhaar:
        await _apiService.uploadAadhar(userId, imageFile, number, context);
        DocumentManager().refreshDocuments(documentType.Aadhaar);
        break;
      case documentType.PAN:
        await _apiService.uploadPan(userId, imageFile, number, context);
        DocumentManager().refreshDocuments(documentType.PAN);
        break;
      case documentType.XMarkSheet:
        await _apiService.uploadXmarksheet(userId, imageFile, context);
        DocumentManager().refreshDocuments(documentType.XMarkSheet);
        break;
      case documentType.XIIMarkSheet:
        await _apiService.uploadXIImarksheet(userId, imageFile, context);
        DocumentManager().refreshDocuments(documentType.XIIMarkSheet);
        break;
      case documentType.MovieTicket:
        await _apiService.uploadMovieTicket(userId, imageFile, context);
        DocumentManager().refreshDocuments(documentType.MovieTicket);
        break;
      case documentType.TrainTicket:
        // Mock train ticket upload
        await _apiService.uploadMovieTicket(userId, imageFile, context);
        DocumentManager().refreshDocuments(documentType.TrainTicket);
        break;
    }
  }

  String getStringFromDoctype(documentType docType) {
    switch (docType) {
      case documentType.Aadhaar:
        return 'Aadhaar';
      case documentType.XMarkSheet:
        return 'X MarkSheet';
      case documentType.XIIMarkSheet:
        return 'XII MarkSheet';
      case documentType.MovieTicket:
        return 'Movie Ticket';
      case documentType.PAN:
        return 'PAN';
      case documentType.TrainTicket:
        return 'Train Ticket';
    }
  }

  Widget _getRightWidget(documentType docType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (docType == documentType.Aadhaar || docType == documentType.PAN) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _number,
                style: TextStyle(
                  fontSize: 16.sp, 
                  letterSpacing: 1.5.w,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "${getStringFromDoctype(widget.docType)} Number",
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      );
    } else if (docType == documentType.XMarkSheet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: markSheetType.values.map((markSheetType markSheetType) {
          final isSelected = _markTpe == markSheetType;
          return InkWell(
            onTap: () {
              setState(() {
                _markTpe = markSheetType;
              });
            },
            borderRadius: BorderRadius.circular(30.r),
            child: Container(
              height: 46.h,
              width: 130.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7C5CFC).withOpacity(0.2)
                    : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C5CFC) : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  markSheetType.toString().split('.').last,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? const Color(0xFFAC94FF) : const Color(0xFF7C5CFC))
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return SizedBox(height: 15.h);
    }
  }
}
