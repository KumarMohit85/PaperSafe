import 'dart:async';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentSelector extends StatefulWidget {
  DocumentSelector({super.key});

  @override
  _DocumentSelectorState createState() => _DocumentSelectorState();
}

class _DocumentSelectorState extends State<DocumentSelector> {
  List<ImageModel?> selectedDocuments = [];
  List<ImageModel?> list = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFetchingDocuments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFetchingDocuments() {
    _timer = Timer.periodic(Duration(microseconds: 100), (timer) async {
      await _fetchDocuments();
      if (list.isNotEmpty) {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchDocuments() async {
    list = DocumentManager().allImages;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < list.length; i++)
          InkWell(
            onTap: () {
              _toggleSelection(list[i]);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                selectedDocuments.contains(list[i])
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: cameraContainer(
                    Image.memory(
                      list[i]!.image!,
                      height: 60,
                      width: 60,
                      fit: BoxFit.fitHeight,
                    ),
                    list[i]!.title!,
                    100,
                    130,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 20.0,
        ),
        ElevatedButton(
          onPressed: selectedDocuments.isNotEmpty
              ? () {
                  DocumentManager().shareDocuments(selectedDocuments);
                }
              : null,
          child: Text("Share"),
        ),
      ],
    );
  }

  Widget cameraContainer(
      Image? image, String title, double height, double width) {
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
        SizedBox(height: 5.h),
        Text(title, textAlign: TextAlign.center),
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
