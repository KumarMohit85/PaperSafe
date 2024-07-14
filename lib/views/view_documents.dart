import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DocumentCategory { identity, all, education }

class ViewDocuments extends StatefulWidget {
  ViewDocuments(
      {super.key, required this.documentCategory, required this.title});
  DocumentCategory documentCategory;
  String title;

  @override
  State<ViewDocuments> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  bool _gridView = true;
  late Future<List<ImageModel?>> _imageListFuture;

  @override
  void initState() {
    super.initState();
    _imageListFuture = _fetchDocuments();
  }

  Future<List<ImageModel?>> _fetchDocuments() async {
    List<ImageModel?> images = [];

    switch (widget.documentCategory) {
      case DocumentCategory.identity:
        images = DocumentManager().identityImages;
        break;
      case DocumentCategory.education:
        images = DocumentManager().educationImages;
        break;
      case DocumentCategory.all:
        images = DocumentManager().allImages;
        break;
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: _getIcon(CupertinoIcons.back, 70),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getIcon(Icons.search),
                  SizedBox(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (!_gridView) {
                              setState(() {
                                _gridView = !_gridView;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _gridView
                                  ? Color.fromARGB(255, 250, 212, 98)
                                  : Colors.white,
                            ),
                            child: _getIcon(Icons.apps),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_gridView) {
                              setState(() {
                                _gridView = !_gridView;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_gridView
                                  ? Color.fromARGB(255, 250, 212, 98)
                                  : Colors.white,
                            ),
                            child: _getIcon(Icons.splitscreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              FutureBuilder<List<ImageModel?>>(
                future: _imageListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _waitingContainer();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _gridView
                        ? _getGridView(snapshot.data!)
                        : _getColumnView(snapshot.data!);
                  } else {
                    return Text("No images available");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIcon(IconData icon, [double size = 37]) {
    return Icon(
      icon,
      size: size,
      color: Color(0xFF580F66),
    );
  }

  Widget _getGridView(List<ImageModel?> list) {
    return Column(
      children: [
        for (int i = 0; i < list.length; i += 2) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int j = i; j < i + 2; j++)
                if (j < list.length && list[j] != null)
                  cameraContainer(
                    Image.memory(
                      list[j]!.image!,
                      height: 60,
                      width: 60,
                      fit: BoxFit.fitHeight,
                    ),
                    list[j]!.title!,
                    130,
                    140,
                  )
                else
                  Container(
                    height: 60,
                    width: 60,
                  ), // Placeholder for missing elements
            ],
          ),
          SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _getColumnView(List<ImageModel?> list) {
    return Column(
      children: [
        for (int i = 0; i < list.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: cameraContainer(
              Image.memory(
                list[i]!.image!,
                height: 60,
                width: 60,
                fit: BoxFit.fitHeight,
              ),
              list[i]!.title!,
              180,
              double.infinity,
            ),
          ),
      ],
    );
  }

  Widget cameraContainer(
      Image image, String title, double height, double width) {
    return Column(
      children: [
        Container(
          height: height.h,
          width: width.w,
          decoration: BoxDecoration(
            border: Border.all(width: 3.sp, color: Color(0xFF580F66)),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: image,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(title),
        ),
      ],
    );
  }

  Widget _waitingContainer() {
    return Container(
      height: 130.h,
      width: 150.w,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
