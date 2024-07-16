import 'dart:io';

import 'package:_first_one/views/add_documents.dart';
import 'package:_first_one/api_services/api_services.dart';
import 'package:_first_one/models/documents_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

enum markSheetType { XMarkSheet, XIIMarkSheet }

class AddDocument extends StatefulWidget {
  AddDocument({super.key, required this.docType, required this.id});
  String id;
  documentType docType;
  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  ApiService _apiService = ApiService();
  markSheetType _markTpe = markSheetType.XMarkSheet;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _number = TextEditingController();
  File? _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 40.h,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    size: 45,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  "Add ${getStringFromDoctype(widget.docType)}",
                  style:
                      TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            _getRightWidget(widget.docType),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _image != null
                    ? Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('No image selected')),
                      ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _askSource(widget.docType);
                        },
                        child: Text("Pick Image")),
                    ElevatedButton(
                        onPressed: () async {
                          if (widget.docType == documentType.XMarkSheet) {
                            if (_markTpe == markSheetType.XMarkSheet) {
                              await _uploadDocument(_image!, widget.docType,
                                  widget.id, _number.text);
                            } else {
                              await _uploadDocument(
                                  _image!,
                                  documentType.XIIMarkSheet,
                                  widget.id,
                                  _number.text);
                            }
                          } else {
                            await _uploadDocument(_image!, widget.docType,
                                widget.id, _number.text);
                          }
                        },
                        child: Text("Upload")),
                  ],
                )
              ],
            ),
          ])),
    );
  }

  void _askSource(documentType doc) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: Container(
            height: 200,
            child: Column(
              children: [
                const ListTile(
                  leading: Text(
                    "Select Source",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFile(ImageSource.camera, doc, widget.id);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera),
                    title: Text(
                      "Camera",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFile(ImageSource.gallery, doc, widget.id);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo),
                    title: Text("Gallery", style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          ));
        });
  }

  void _pickImageFile(
      ImageSource source, documentType doc, String userId) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        print(pickedFile.path);
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadDocument(
      File imageFile, documentType doc, String userId, String number) async {
    switch (doc) {
      case documentType.Aadhaar:
        await _apiService.uploadAadhar(userId, imageFile, context, number);
        DocumentManager().refreshDocuments(documentType.Aadhaar);
        break;
      case documentType.PAN:
        await _apiService.uploadPan(userId, imageFile, context, number);
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
      // TODO: Handle this case.
    }
  }

  String getStringFromDoctype(documentType docType) {
    switch (docType) {
      case documentType.Aadhaar:
        return 'Aadhaar';
      case documentType.XMarkSheet:
        return 'XMarkSheet';
      case documentType.XIIMarkSheet:
        return 'XIIMarkSheet';
      case documentType.MovieTicket:
        return 'MovieTicket';
      case documentType.PAN:
        return 'PAN';
      case documentType.TrainTicket:
        return 'TrainTicket';
      default:
        return 'Unknown Document';
    }
  }

  bool isNumberRequired(documentType docType) {
    return docType == documentType.Aadhaar || docType == documentType.PAN;
  }

  Widget _getRightWidget(documentType docType) {
    if (docType == documentType.Aadhaar || docType == documentType.PAN) {
      return Column(
        children: [
          Container(
            height: 43.h,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(60.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: TextField(
                controller: _number,
                style: TextStyle(fontSize: 18.sp, letterSpacing: 1.5.w),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "${getStringFromDoctype(widget.docType)} Number",
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      );
    } else if (docType == documentType.XMarkSheet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: markSheetType.values.map((markSheetType markSheetType) {
          return InkWell(
            onTap: () {
              setState(() {
                _markTpe = markSheetType;
              });
            },
            child: Container(
              height: 51.h,
              width: 131.w,
              decoration: BoxDecoration(
                  border: _markTpe == markSheetType
                      ? Border.all(color: Colors.deepPurple, width: 2)
                      : Border.all(width: 0),
                  borderRadius: BorderRadius.circular(60.r)),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: 50.h,
                  width: 130.w,
                  decoration: BoxDecoration(
                      color: _markTpe == markSheetType
                          ? Color.fromARGB(255, 219, 102, 239)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(60.r)),
                  child: Center(
                    child: Text(
                      markSheetType.toString().split('.').last,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return SizedBox(
        height: 15.h,
      );
    }
  }
}
