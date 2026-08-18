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
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: Colors.tealAccent,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null && code != _qrCode) {
                    setState(() => _qrCode = code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned QR Code: $code')),
                    );
                    break;
                  }
                }
              },
            ),
          ),
          if (_qrCode != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              color: const Color(0xFF1E293B),
              child: Text(
                'Last scanned: $_qrCode',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
