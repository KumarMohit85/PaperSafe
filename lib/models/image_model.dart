import 'dart:typed_data';

import 'package:_first_one/models/documents_manager.dart';

DocumentManager docManager = DocumentManager();

class ImageModel {
  String? title;
  Uint8List? image;

  ImageModel({required this.title, required this.image});
}
