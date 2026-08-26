import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:papersafe/core/services/ocr_service.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kCircle = Color(0xFF1A2D4A);

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _cameraController;
  final OCRService _ocrService = OCRService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  FlashMode _flashMode = FlashMode.off;
  int _selectedDocType = 0;

  final _docTypes = ['Aadhaar', 'PAN', 'Passport', 'Custom'];
  final _docTypeFlags = ['🪪', '🟡', '🟦', '📄'];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    final newMode =
        _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _cameraController!.setFlashMode(newMode);
    setState(() => _flashMode = newMode);
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final XFile picture = await _cameraController!.takePicture();
      final File imageFile = File(picture.path);
      final ExtractedDocumentData result =
          await _ocrService.processImage(imageFile);
      if (mounted) _showResultBottomSheet(result, imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process scan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isProcessing = true);
    try {
      final File imageFile = File(image.path);
      final ExtractedDocumentData result =
          await _ocrService.processImage(imageFile);
      if (mounted) _showResultBottomSheet(result, imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showResultBottomSheet(ExtractedDocumentData data, File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kAccent),
                      ),
                      child: Text(
                        data.docTypeTitle,
                        style: const TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (data.documentNumber != null) ...[
                  const Text('Extracted Document Number:',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.documentNumber!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: _kAccent),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: data.documentNumber!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Document number copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (data.dob != null) ...[
                  const Text('Date of Birth:',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    data.dob!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Extracted Raw Text:',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        data.rawText.isEmpty
                            ? 'No text detected'
                            : data.rawText,
                        style: const TextStyle(
                            color: Color(0xDEFFFFFF),
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: data.rawText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'All text copied to clipboard!')),
                          );
                        },
                        icon: const Icon(Icons.copy_all,
                            color: Colors.white),
                        label: const Text('Copy All',
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Document extracted successfully!')),
                          );
                        },
                        icon: const Icon(Icons.check,
                            color: Colors.white),
                        label: const Text('Use Data',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kAccent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.7),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SMART OCR SCANNER',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: const Color(0xFF8B9ABB),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Scan a document',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Local text recognition — your data never leaves the device.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8B9ABB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Document type pill tabs ──────────────────────────
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: _docTypes.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (_, i) {
                        final selected = _selectedDocType == i;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDocType = i),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color:
                                  selected ? _kAccent : _kSurface,
                              borderRadius:
                                  BorderRadius.circular(20.r),
                              border: Border.all(
                                color: selected
                                    ? _kAccent
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_docTypeFlags[i],
                                    style:
                                        const TextStyle(fontSize: 12)),
                                const SizedBox(width: 5),
                                Text(
                                  _docTypes[i],
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF8B9ABB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Camera viewfinder ────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Camera frame card
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.w),
                            height:
                                MediaQuery.of(context).size.height *
                                    0.33,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius:
                                  BorderRadius.circular(18.r),
                              border: Border.all(
                                  color: Colors.white10, width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(18.r),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Camera preview
                                  if (_isCameraInitialized &&
                                      _cameraController != null)
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _cameraController!
                                              .value
                                              .previewSize!
                                              .height,
                                          height: _cameraController!
                                              .value
                                              .previewSize!
                                              .width,
                                          child: CameraPreview(
                                              _cameraController!),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      color: _kElevated,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .document_scanner_outlined,
                                            color: _kAccent,
                                            size: 48.sp,
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            'Position document inside frame',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Hold steady for best results',
                                            style: TextStyle(
                                              color: const Color(
                                                  0xFF8B9ABB),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Corner bracket overlay
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _CornerPainter(),
                                    ),
                                  ),

                                  // Processing overlay
                                  if (_isProcessing)
                                    Container(
                                      color: Colors.black54,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                              color: _kAccent),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Analyzing with ML Kit...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // ── Controls row ──────────────────────────────
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.w),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                // Flash toggle
                                _controlButton(
                                  icon: _flashMode == FlashMode.torch
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  onTap: _toggleFlash,
                                  active:
                                      _flashMode == FlashMode.torch,
                                ),

                                // Capture button
                                GestureDetector(
                                  onTap: _captureAndScan,
                                  child: Container(
                                    width: 68.w,
                                    height: 68.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _kAccent
                                              .withOpacity(0.4),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 52.w,
                                        height: 52.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _kAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Gallery picker
                                _controlButton(
                                  icon: Icons.photo_library_outlined,
                                  onTap: _pickFromGallery,
                                  active: false,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // ── Upload from gallery card ──────────────────
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20.w),
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius:
                                    BorderRadius.circular(14.r),
                                border: Border.all(
                                    color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: _kAccent
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10.r),
                                    ),
                                    child: const Icon(
                                      Icons.upload_outlined,
                                      color: _kAccent,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upload from gallery',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'PDF, JPG, PNG up to 10 MB',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(
                                                0xFF8B9ABB),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.crop_original,
                                    color: Color(0xFF8B9ABB),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: active ? _kAccent.withOpacity(0.2) : _kSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? _kAccent : Colors.white12,
          ),
        ),
        child: Icon(icon,
            color: active ? _kAccent : const Color(0xFF8B9ABB),
            size: 20),
      ),
    );
  }
}

// Draws 4 blue corner brackets on the viewfinder
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4361EE)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    final w = size.width;
    final h = size.height;
    final pad = 20.0;

    // Top-left
    canvas.drawLine(Offset(pad, pad + len), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad), paint);
    // Top-right
    canvas.drawLine(Offset(w - pad - len, pad), Offset(w - pad, pad), paint);
    canvas.drawLine(Offset(w - pad, pad), Offset(w - pad, pad + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(pad, h - pad - len), Offset(pad, h - pad), paint);
    canvas.drawLine(Offset(pad, h - pad), Offset(pad + len, h - pad), paint);
    // Bottom-right
    canvas.drawLine(
        Offset(w - pad - len, h - pad), Offset(w - pad, h - pad), paint);
    canvas.drawLine(
        Offset(w - pad, h - pad - len), Offset(w - pad, h - pad), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
