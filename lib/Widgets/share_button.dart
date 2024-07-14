import 'dart:async';
import 'package:_first_one/models/documents_manager.dart';
import 'package:_first_one/models/image_model.dart';
import 'package:flutter/material.dart';

class ShareButton extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  ShareButton({required this.scaffoldKey});

  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
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

  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? InkWell(
            onTap: () {
              widget.scaffoldKey.currentState!.openEndDrawer();
            },
            child: const Icon(
              Icons.share,
              size: 30.0,
            ),
          )
        : Icon(
            Icons.share,
            size: 30.0,
            color: Colors.grey[300],
          );
  }
}
