import 'package:flutter/material.dart';
import 'package:papersafe/core/widgets/glassmorphism.dart';
import 'package:papersafe/widgets/document_card.dart';
import 'package:papersafe/core/theme/app_colors.dart';
import 'package:papersafe/core/theme/app_theme.dart';
import 'package:papersafe/views/login_signup.dart';
import 'package:papersafe/views/mobile_otp.dart';
import 'package:papersafe/views/tell_more.dart';
import 'package:papersafe/views/homepage.dart';
import 'package:papersafe/views/scanner_page.dart';
import 'package:papersafe/views/ai_assistant_page.dart';
import 'package:papersafe/views/qr_scanner_page.dart';
import 'package:papersafe/views/qr_generator_page.dart';
import 'package:papersafe/views/nearby_sharing_page.dart';
import 'package:papersafe/core/router/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Sample document data – in real app this will come from provider
  final List<Map<String, dynamic>> _documents = const [
    {"title": "Aadhaar Card", "type": documentType.Aadhaar, "icon": Icons.account_box},
    {"title": "PAN Card", "type": documentType.PAN, "icon": Icons.credit_card},
    {"title": "Movie Ticket", "type": documentType.MovieTicket, "icon": Icons.movie},
    {"title": "Train Ticket", "type": documentType.TrainTicket, "icon": Icons.train},
    // New features
    {"title": "Scanner", "type": documentType.Scanner, "icon": Icons.camera_alt},
    {"title": "AI Assistant", "type": documentType.AIAssistant, "icon": Icons.smart_toy},
    {"title": "QR Tools", "type": documentType.QR, "icon": Icons.qr_code},
    {"title": "Nearby Sharing", "type": documentType.Nearby, "icon": Icons.share},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                 // Navigate based on document type
                 switch (doc["type"]) {
                   case documentType.Scanner:
                     Navigator.of(context).pushNamed('/scanner');
                     break;
                   case documentType.AIAssistant:
                  Navigator.of(context).pushNamed(AppRoutes.aiChat);
                  break;
                   case documentType.QR:
                     Navigator.of(context).pushNamed('/qr');
                     break;
                   case documentType.Nearby:
                     Navigator.of(context).pushNamed('/nearby');
                     break;
                   default:
                     // Existing document types – placeholder navigation
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

enum documentType { Aadhaar, PAN, XMarkSheet, XIIMarkSheet, MovieTicket, TrainTicket, Scanner, AIAssistant, QR, Nearby }
