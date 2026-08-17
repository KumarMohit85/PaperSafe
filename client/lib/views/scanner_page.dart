import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  late final TextRecognizer _textRecognizer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _textRecognizer = TextRecognizer();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
    _controller = CameraController(backCamera, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognized = await _textRecognizer.processImage(inputImage);
      final extracted = recognized.blocks.map((b) => b.text).join('\n');
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Extracted Text'),
          content: SingleChildScrollView(child: Text(extracted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      // ignore errors for now
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Document Scanner')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _captureAndRecognize,
                      icon: const Icon(Icons.camera),
                      label: Text(_isProcessing ? 'Processing...' : 'Capture'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
