import 'dart:io';
import 'dart:typed_data';

import 'package:_first_one/api_services/api_services.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class getImagesfromZip {
  ApiService _apiService = ApiService();

  Future<List<File>?> downloadAndShowImages(String userId) async {
    try {
      final zipFile = await _apiService.downloadZipFile(userId);
      if (zipFile != null) {
        final images = await extractZipFile(zipFile);
        return images;
      } else {
        print('Failed to download zip file.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<File>> extractZipFile(File zipFile) async {
    List<File> extractedFiles = [];
    try {
      final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      for (final file in archive) {
        final filename = '$tempPath/${file.name}';
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedFiles.add(outFile);
        }
      }
    } catch (e) {
      print('Error extracting zip file: $e');
    }
    return extractedFiles;
  }
}
