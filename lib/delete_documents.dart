import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageDocuments extends StatefulWidget {
  ManageDocuments({super.key, required this.title});
  final String title;

  @override
  State<ManageDocuments> createState() => _ManageDocumentsState();
}

class _ManageDocumentsState extends State<ManageDocuments> {
  bool _gridView = true;
  List<ImageModel?> selectedDocuments = [];
  List<ImageModel?> list = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    list = await DocumentManager().allImages;
    setState(() {});
  }

  void _toggleSelection(ImageModel? imageModel) {
    setState(() {
      if (selectedDocuments.contains(imageModel)) {
        selectedDocuments.remove(imageModel);
      } else {
        selectedDocuments.add(imageModel);
      }
    });
  }

  void _deleteSelectedDocuments() {
    setState(() {
      for (var doc in selectedDocuments) {
        list.remove(doc);

        DocumentManager()
            .deleteDocument(doc!.title!); // Assuming title is unique
      }
      selectedDocuments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(10.w, 30.h, 30.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: _getIcon(CupertinoIcons.back, 70),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    widget.title,
                    style:
                        TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              list.isNotEmpty
                  ? _gridView
                      ? _getgridView(list)
                      : _getColumnView(list)
                  : Text("Image list is empty"),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: selectedDocuments.isNotEmpty
                    ? _deleteSelectedDocuments
                    : null,
                child: Text("Delete Selected Documents"),
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
      size: 37,
      color: Color(0xFF580F66),
    );
  }

  Widget _getgridView(List<ImageModel?> list) {
    return Column(
      children: [
        for (int i = 0; i < list.length; i += 2) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int j = i; j < i + 2; j++)
                if (j < list.length && list[j] != null)
                  _buildSelectableContainer(list[j])
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
            child: _buildSelectableContainer(list[i]),
          ),
      ],
    );
  }

  Widget _buildSelectableContainer(ImageModel? imageModel) {
    return InkWell(
      onTap: () {
        _toggleSelection(imageModel);
      },
      child: Row(
        children: [
          Checkbox(
            value: selectedDocuments.contains(imageModel),
            onChanged: (bool? value) {
              _toggleSelection(imageModel);
            },
          ),
          cameraContainer(
            Image.memory(
              imageModel!.image!,
              height: 60,
              width: 60,
              fit: BoxFit.fitHeight,
            ),
            imageModel.title!,
            100,
            110,
          ),
        ],
      ),
    );
  }

  cameraContainer(Image? image, String title, double height, double width) {
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
            child: image ?? _waitingContainer(),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(title),
        ),
      ],
    );
  }

  _waitingContainer() {
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
