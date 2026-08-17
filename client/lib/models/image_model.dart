import 'dart:typed_data';

import 'package:papersafe/models/documents_manager.dart';

DocumentManager docManager = DocumentManager();

class ImageModel {
  String? title;
  Uint8List? image;

  ImageModel({required this.title, required this.image});
}
