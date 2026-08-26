import 'dart:io';
import 'dart:typed_data';
import 'package:papersafe/views/add_documents.dart';
import 'package:papersafe/api_services/api_services.dart';
import 'package:papersafe/models/extrac_images.dart';
import 'package:papersafe/models/image_model.dart';
import 'package:papersafe/models/user.dart';
import 'package:papersafe/models/user_manager.dart';
import 'package:papersafe/views/your_documents.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentManager {
  static final DocumentManager _instance = DocumentManager._internal();

  factory DocumentManager() {
    return _instance;
  }

  DocumentManager._internal();

  final ApiService _apiService = ApiService();

  Map<String, Uint8List?> documents = {};
  Map<String, List<File>?> movieTickets = {};

  List<ImageModel?> allImages = [];
  List<ImageModel?> identityImages = [];
  List<ImageModel?> educationImages = [];
  getImagesfromZip _getZipImages = getImagesfromZip();

  void reset() {
    documents.clear();
    movieTickets.clear();
  }

  void initialize() async {
    User? user = await UserManager().getUser();

    print("initialize function called from documents manager");

    // Initialize maps and lists
    documents = {};
    movieTickets = {};
    allImages = [];
    identityImages = [];
    educationImages = [];

    if (ApiService.useMockBackend) {
      await loadMockAssets();
    } else if (user != null) {
      await downloadAllDocuments(user.id!);
      await populateAllImages();
    } else {
      clearDocuments();
    }
  }

  Future<void> loadMockAssets() async {
    try {
      print("Loading mock assets in DocumentManager");
      final prefs = await SharedPreferences.getInstance();

      // 1. Aadhaar
      final aadhaarPath = prefs.getString('mock_persist_aadhaar');
      if (aadhaarPath != null && await File(aadhaarPath).exists()) {
        documents["aadhaar"] = await File(aadhaarPath).readAsBytes();
      } else {
        final aadharData = await rootBundle.load('assets/images/aadhar_card_dummy.png');
        documents["aadhaar"] = aadharData.buffer.asUint8List();
      }

      // 2. PAN
      final panPath = prefs.getString('mock_persist_pan');
      if (panPath != null && await File(panPath).exists()) {
        documents["pan"] = await File(panPath).readAsBytes();
      } else {
        final panData = await rootBundle.load('assets/images/indian_flag.png');
        documents["pan"] = panData.buffer.asUint8List();
      }

      // 3. Marksheets
      final xPath = prefs.getString('mock_persist_xMarkSheet');
      if (xPath != null && await File(xPath).exists()) {
        documents["xMarkSheet"] = await File(xPath).readAsBytes();
      } else {
        final marksheetData = await rootBundle.load('assets/images/marksheet.png');
        documents["xMarkSheet"] = marksheetData.buffer.asUint8List();
      }

      final xiiPath = prefs.getString('mock_persist_xiiMarkSheet');
      if (xiiPath != null && await File(xiiPath).exists()) {
        documents["xiiMarkSheet"] = await File(xiiPath).readAsBytes();
      } else {
        final marksheetData = await rootBundle.load('assets/images/marksheet.png');
        documents["xiiMarkSheet"] = marksheetData.buffer.asUint8List();
      }

      // 4. Movie Tickets
      final ticketPaths = prefs.getStringList('mock_persist_movieTickets') ?? [];
      final List<File> filesList = [];
      for (final path in ticketPaths) {
        final f = File(path);
        if (await f.exists()) {
          filesList.add(f);
        }
      }
      if (filesList.isNotEmpty) {
        movieTickets["tickets"] = filesList;
      } else {
        final movieTicketData = await rootBundle.load('assets/images/movie_ticket.png');
        final tempDir = await getTemporaryDirectory();
        final movieFile = File('${tempDir.path}/mock_movie_ticket.png');
        await movieFile.writeAsBytes(movieTicketData.buffer.asUint8List());
        movieTickets["tickets"] = [movieFile];
      }

      await populateAllImages();
    } catch (e) {
      print("Error loading mock assets: $e");
    }
  }

  Future<void> persistMockUpload(String docType, File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();

      if (docType == 'movieTicket') {
        final persistentFile = File('${appDir.path}/mock_ticket_${DateTime.now().millisecondsSinceEpoch}.png');
        await persistentFile.writeAsBytes(await file.readAsBytes());

        final currentPaths = prefs.getStringList('mock_persist_movieTickets') ?? [];
        currentPaths.add(persistentFile.path);
        await prefs.setStringList('mock_persist_movieTickets', currentPaths);

        movieTickets['tickets'] ??= [];
        movieTickets['tickets']!.add(persistentFile);
      } else {
        final persistentFile = File('${appDir.path}/mock_${docType}.png');
        await persistentFile.writeAsBytes(await file.readAsBytes());
        await prefs.setString('mock_persist_${docType}', persistentFile.path);

        documents[docType] = await persistentFile.readAsBytes();
      }
      await populateAllImages();
    } catch (e) {
      print("Error persisting mock upload: $e");
    }
  }

  Future<void> deleteMockPersist(String card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (card == 'MovieTicket' || card == 'MovieTicket1' || card == 'MovieTicket2' || card == 'MovieTicket3') {
        final ticketPaths = prefs.getStringList('mock_persist_movieTickets') ?? [];
        for (final path in ticketPaths) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
        await prefs.remove('mock_persist_movieTickets');
        movieTickets.clear();
      } else {
        final keyName = card.toLowerCase();
        final prefKey = 'mock_persist_$keyName';
        final path = prefs.getString(prefKey);
        if (path != null) {
          final f = File(path);
          if (await f.exists()) await f.delete();
          await prefs.remove(prefKey);
        }
        documents.remove(keyName);
      }
      await populateAllImages();
    } catch (e) {
      print("Error deleting mock persistent storage: $e");
    }
  }

  void refreshDocuments(documentType docType) {
    if (ApiService.useMockBackend) {
      populateAllImages();
      return;
    }
    UserManager.instance.userStream.listen((user) async {
      switch (docType) {
        case documentType.Aadhaar:
          await downloadAadhaar(user!.id!);
          break;
        case documentType.XMarkSheet:
          await downloadXMarkSheet(user!.id!);
          break;
        case documentType.XIIMarkSheet:
          await downloadXIIMarkSheet(user!.id!);
          break;
        case documentType.MovieTicket:
          await downloadMovieTickets(user!.id!);
          break;
        case documentType.PAN:
          await downloadPAN(user!.id!);
          break;
        case documentType.TrainTicket:
          print("no train ticket to download");
          break;
        default:
          print("wrong doc type selected from refresh doc");
          break;
      }

      await populateAllImages();
    });
  }

  Future<void> downloadAllDocuments(String userId) async {
    print("Downloading all documents for user: $userId");

    await downloadAadhaar(userId);
    await downloadPAN(userId);
    await downloadXIIMarkSheet(userId);
    await downloadXMarkSheet(userId);
    await downloadMovieTickets(userId);
    // Add more document download calls as needed
  }

  Future<void> downloadAadhaar(String userId) async {
    documents["aadhaar"] = await _apiService.fetchImageData(userId, "Aadhaar");
  }

  Future<void> downloadPAN(String userId) async {
    documents["pan"] = await _apiService.fetchImageData(userId, "PAN");
  }

  Future<void> downloadXIIMarkSheet(String userId) async {
    documents["xiiMarkSheet"] =
        await _apiService.fetchImageData(userId, "XIIMarkSheet");
  }

  Future<void> downloadXMarkSheet(String userId) async {
    documents["xMarkSheet"] =
        await _apiService.fetchImageData(userId, "XMarkSheet");
  }

  Future<void> downloadMovieTickets(String userId) async {
    movieTickets["tickets"] = await _getZipImages.downloadAndShowImages(userId);
  }

  void clearDocuments() {
    documents.clear();
    movieTickets.clear();
  }

  Future<void> deleteDocument(String card) async {
    User? user = await UserManager().getUser();
    if (card == 'MovieTicket1' ||
        card == 'MovieTicket2' ||
        card == 'MovieTicket3') {
      movieTickets.clear();
      await _apiService.deleteImage("MovieTicket", user!.id!);
    } else {
      await _apiService.deleteImage(
          card, user!.id!); // Call API to delete from backend
      documents.remove(DoctypeToCardType(
          stringToDocumentType(card))); // Remove from local map
    }

    // Clear local lists
    allImages.removeWhere((img) => img?.title == card);
    identityImages.removeWhere((img) => img?.title == card);
    educationImages.removeWhere((img) => img?.title == card);
    await populateAllImages(); // Update local document list
  }

  Uint8List? getDocument(String card) {
    return documents[card];
  }

  Future<List<ImageModel?>?> populateAllImages() async {
    // Reinitialize allImages, identityImages, and educationImages
    allImages = [
      if (getDocument("aadhaar") != null)
        ImageModel(title: "Aadhaar", image: getDocument("aadhaar")),
      if (getDocument("pan") != null)
        ImageModel(title: "PAN", image: getDocument("pan")),
      if (getDocument("xiiMarkSheet") != null)
        ImageModel(title: "XIIMarkSheet", image: getDocument("xiiMarkSheet")),
      if (getDocument("xMarkSheet") != null)
        ImageModel(title: "XMarkSheet", image: getDocument("xMarkSheet")),
    ];

    identityImages = [
      if (getDocument("aadhaar") != null)
        ImageModel(title: "Aadhaar", image: getDocument("aadhaar")),
      if (getDocument("pan") != null)
        ImageModel(title: "PAN", image: getDocument("pan")),
    ];

    educationImages = [
      if (getDocument("xiiMarkSheet") != null)
        ImageModel(title: "XIIMarkSheet", image: getDocument("xiiMarkSheet")),
      if (getDocument("xMarkSheet") != null)
        ImageModel(title: "XMarkSheet", image: getDocument("xMarkSheet")),
    ];

    // Clear movie tickets list
    if (movieTickets["tickets"] != null) {
      for (var i = 0; i < movieTickets["tickets"]!.length; i++) {
        Uint8List? imageData = await movieTickets["tickets"]![i].readAsBytes();
        allImages
            .add(ImageModel(title: "MovieTicket${i + 1}", image: imageData));
      }
    }
    return allImages;
  }

  Future<void> shareDocuments(List<ImageModel?>? list) async {
    if (list == null || list.isEmpty) {
      print("No documents to share.");
      return;
    }

    print("Share file function called from DocumentManager");

    final tempDir = await getTemporaryDirectory();
    List<XFile> xFiles = [];
    List<String> titles = [];

    for (var imageModel in list) {
      if (imageModel?.image != null) {
        final filePath = '${tempDir.path}/${imageModel!.title}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageModel.image!);
        xFiles.add(XFile(filePath));
        titles.add(imageModel.title!);
      }
    }

    if (xFiles.isNotEmpty) {
      String sharedText = 'Sharing my documents:\n' + titles.join(', ');
      await Share.shareXFiles(xFiles, text: sharedText);
    } else {
      print("No valid documents to share.");
    }
  }

  String DoctypeToCardType(documentType docType) {
    switch (docType) {
      case documentType.Aadhaar:
        return "aadhaar";
      case documentType.XMarkSheet:
        return "xMarkSheet";
      case documentType.XIIMarkSheet:
        return "xiiMarkSheet";
      case documentType.MovieTicket:
        return "tickets";
      case documentType.PAN:
        return "pan";
      case documentType.TrainTicket:
        return "nothing";
      default:
        return "default";
    }
  }

  String documentTypeToString(documentType type) {
    return type.toString().split('.').last;
  }

  // Convert from String to documentType
  documentType stringToDocumentType(String type) {
    return documentType.values.firstWhere(
      (e) => documentTypeToString(e) == type,
      orElse: () => throw ArgumentError('Invalid documentType string'),
    );
  }
  // documentType string2DocType(String card){
  //   switch {

  //   }
  // }
}
