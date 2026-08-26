import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/core/theme/app_colors.dart';
import 'package:papersafe/core/theme/app_theme.dart';
import 'package:papersafe/core/router/app_router.dart';
import 'package:papersafe/core/widgets/glassmorphism.dart';
import 'package:papersafe/Widgets/document_card.dart';
import 'package:papersafe/views/view_documents.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> _documents = const [
    {
      "title": "Aadhaar Card",
      "type": documentType.Aadhaar,
      "icon": Icons.account_box
    },
    {"title": "PAN Card", "type": documentType.PAN, "icon": Icons.credit_card},
    {
      "title": "Movie Ticket",
      "type": documentType.MovieTicket,
      "icon": Icons.movie
    },
    {
      "title": "Train Ticket",
      "type": documentType.TrainTicket,
      "icon": Icons.train
    },
    {
      "title": "Scanner",
      "type": documentType.Scanner,
      "icon": Icons.camera_alt
    },
    {
      "title": "AI Assistant",
      "type": documentType.AIAssistant,
      "icon": Icons.smart_toy
    },
    {"title": "QR Tools", "type": documentType.QR, "icon": Icons.qr_code},
    {
      "title": "Nearby Sharing",
      "type": documentType.Nearby,
      "icon": Icons.share
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = (width / 180).floor().clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PaperSafe'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassMorphism(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(12.r),
        borderRadius: 20,
        blurSigma: 12,
        child: GridView.builder(
          padding: EdgeInsets.all(8.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12.r,
            mainAxisSpacing: 12.r,
          ),
          itemCount: _documents.length,
          itemBuilder: (context, index) {
            final doc = _documents[index];
            return DocumentCard(
              title: doc["title"],
              iconData: doc["icon"],
              onTap: () {
                switch (doc["type"]) {
                  case documentType.Scanner:
                    context.push(AppRoutes.scanner);
                    break;
                  case documentType.AIAssistant:
                    context.push(AppRoutes.aiChat);
                    break;
                  case documentType.QR:
                    context.push(AppRoutes.qrScanner);
                    break;
                  case documentType.Nearby:
                    context.push(AppRoutes.nearbyShare);
                    break;
                  case documentType.Aadhaar:
                  case documentType.PAN:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewDocuments(
                          documentCategory: DocumentCategory.identity,
                          title: "Identity Documents",
                        ),
                      ),
                    );
                    break;
                  case documentType.MovieTicket:
                  case documentType.TrainTicket:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewDocuments(
                          documentCategory: DocumentCategory.all,
                          title: "All Documents",
                        ),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

enum documentType {
  Aadhaar,
  PAN,
  XMarkSheet,
  XIIMarkSheet,
  MovieTicket,
  TrainTicket,
  Scanner,
  AIAssistant,
  QR,
  Nearby
}
