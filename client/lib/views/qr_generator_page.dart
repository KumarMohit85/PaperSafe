import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String _data = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator')),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter data',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () {
                setState(() => _data = _controller.text.trim());
              },
              child: const Text('Generate QR'),
            ),
            SizedBox(height: 24.h),
            if (_data.isNotEmpty)
              Center(
                child: QrImage(
                  data: _data,
                  version: QrVersions.auto,
                  size: 200.r,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
