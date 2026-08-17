import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? _qrCode;

  @override
n  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              allowDuplicates: false,
              onDetect: (barcode, args) {
                final String? code = barcode.rawValue;
                if (code != null && code != _qrCode) {
                  setState(() => _qrCode = code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanned: $code')),
                  );
                }
              },
            ),
          ),
          if (_qrCode != null)
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Text('Last scanned: $_qrCode'),
            ),
        ],
      ),
    );
  }
}
