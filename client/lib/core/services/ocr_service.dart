import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum DocumentType {
  aadhaar,
  pan,
  passport,
  drivingLicense,
  creditCard,
  unknown,
}

class ExtractedDocumentData {
  final DocumentType docType;
  final String? documentNumber;
  final String? name;
  final String? dob;
  final String? fatherName;
  final String? expiryDate;
  final String rawText;

  ExtractedDocumentData({
    required this.docType,
    this.documentNumber,
    this.name,
    this.dob,
    this.fatherName,
    this.expiryDate,
    required this.rawText,
  });

  String get docTypeTitle {
    switch (docType) {
      case DocumentType.aadhaar:
        return 'Aadhaar Card';
      case DocumentType.pan:
        return 'PAN Card';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.creditCard:
        return 'Credit / Debit Card';
      case DocumentType.unknown:
        return 'General Document';
    }
  }
}

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Process image file and extract structured fields based on detected document type.
  Future<ExtractedDocumentData> processImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    final String fullText = recognizedText.text;

    return parseText(fullText);
  }

  /// Parse raw string into structured ExtractedDocumentData
  ExtractedDocumentData parseText(String text) {
    final upper = text.toUpperCase();

    // 1. Detect Document Type
    if (upper.contains('GOVERNMENT OF INDIA') && (upper.contains('AADHAAR') || upper.contains('MERA AADHAAR') || RegExp(r'\d{4}\s?\d{4}\s?\d{4}').hasMatch(text))) {
      return _parseAadhaar(text);
    } else if (upper.contains('INCOME TAX DEPARTMENT') || RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]{1}').hasMatch(text)) {
      return _parsePAN(text);
    } else if (upper.contains('PASSPORT') || RegExp(r'[A-Z]{1}[0-9]{7}').hasMatch(text)) {
      return _parsePassport(text);
    } else if (upper.contains('DRIVING LICENCE') || upper.contains('DRIVING LICENSE') || RegExp(r'[A-Z]{2}[0-9]{2}\s?[0-9]{11}').hasMatch(text)) {
      return _parseDrivingLicense(text);
    }

    return ExtractedDocumentData(
      docType: DocumentType.unknown,
      rawText: text,
    );
  }

  ExtractedDocumentData _parseAadhaar(String text) {
    // Aadhaar 12-digit number pattern
    final aadhaarMatch = RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\b').firstMatch(text);
    final docNumber = aadhaarMatch?.group(0);

    // DOB pattern: DD/MM/YYYY
    final dobMatch = RegExp(r'\b(DOB|Date of Birth|Year of Birth)[:\s]*(\d{2}/\d{2}/\d{4}|\d{4})\b', caseSensitive: false).firstMatch(text);
    final dob = dobMatch?.group(2);

    return ExtractedDocumentData(
      docType: DocumentType.aadhaar,
      documentNumber: docNumber,
      dob: dob,
      rawText: text,
    );
  }

  ExtractedDocumentData _parsePAN(String text) {
    // PAN number pattern: 5 letters, 4 numbers, 1 letter
    final panMatch = RegExp(r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b').firstMatch(text);
    final docNumber = panMatch?.group(0);

    // DOB pattern
    final dobMatch = RegExp(r'\b\d{2}/\d{2}/\d{4}\b').firstMatch(text);
    final dob = dobMatch?.group(0);

    return ExtractedDocumentData(
      docType: DocumentType.pan,
      documentNumber: docNumber,
      dob: dob,
      rawText: text,
    );
  }

  ExtractedDocumentData _parsePassport(String text) {
    final passportMatch = RegExp(r'\b[A-Z]{1}[0-9]{7}\b').firstMatch(text);
    final docNumber = passportMatch?.group(0);

    return ExtractedDocumentData(
      docType: DocumentType.passport,
      documentNumber: docNumber,
      rawText: text,
    );
  }

  ExtractedDocumentData _parseDrivingLicense(String text) {
    final dlMatch = RegExp(r'\b[A-Z]{2}[0-9]{2}\s?[0-9]{11}\b').firstMatch(text);
    final docNumber = dlMatch?.group(0);

    return ExtractedDocumentData(
      docType: DocumentType.drivingLicense,
      documentNumber: docNumber,
      rawText: text,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
