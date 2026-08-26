import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kCircle = Color(0xFF1A2D4A);

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  final MobileScannerController _scanController = MobileScannerController();

  String _qrData = 'https://papersafe.app/arjun';
  String? _scannedCode;

  // Mock recent activity
  final _recentActivity = [
    (title: 'Aadhaar number', time: '2 hours ago', tag: 'text'),
    (title: 'Wi-Fi credentials', time: 'Yesterday', tag: 'wifi'),
    (title: 'Flight boarding pass', time: '3 days ago', tag: 'url'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _inputController.text = _qrData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _scanController.dispose();
    super.dispose();
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
            Positioned(
              bottom: 60,
              left: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.5),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR CODE TOOLS',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: const Color(0xFF8B9ABB),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Generate & scan',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Offline QR creation and instant camera scanning.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8B9ABB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Tab toggle ───────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: _kAccent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF8B9ABB),
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_2, size: 16),
                                SizedBox(width: 6),
                                Text('Generate'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner, size: 16),
                                SizedBox(width: 6),
                                Text('Scan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Tab content ──────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGenerateTab(),
                        _buildScanTab(),
                      ],
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

  // ── GENERATE TAB ─────────────────────────────────────────────────
  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR code display card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // QR image on white background
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: _qrData.isNotEmpty
                      ? QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 180.r,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        )
                      : SizedBox(
                          width: 180.r,
                          height: 180.r,
                          child: const Center(
                            child: Text('Enter text below',
                                style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Encoding',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF8B9ABB),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _qrData.isEmpty ? '—' : _qrData,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Text input label
          Text(
            'Text or URL to encode',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // Text input field
          TextField(
            controller: _inputController,
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
            onChanged: (val) => setState(() => _qrData = val.trim()),
            decoration: InputDecoration(
              filled: true,
              fillColor: _kSurface,
              hintText: 'https://...',
              hintStyle: const TextStyle(color: Color(0xFF4A5568)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _kAccent, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Action buttons: Copy / Save / Share
          Row(
            children: [
              _actionButton(
                icon: Icons.copy_outlined,
                label: 'Copy',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _qrData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              SizedBox(width: 10.w),
              _actionButton(
                icon: Icons.download_outlined,
                label: 'Save',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR saved to gallery')),
                  );
                },
              ),
              SizedBox(width: 10.w),
              _actionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => Share.share(_qrData),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Recent activity header
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: Color(0xFF8B9ABB), size: 16),
              SizedBox(width: 6.w),
              Text(
                'Recent activity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Recent activity list
          ..._recentActivity.map((item) => _recentActivityItem(item)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 20.sp),
              SizedBox(height: 4.h),
              Text(label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentActivityItem(
      ({String title, String time, String tag}) item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: _kElevated,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.qr_code_2,
                color: Color(0xFF8B9ABB), size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text(item.time,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B9ABB),
                    )),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _kElevated,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF8B9ABB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SCAN TAB ─────────────────────────────────────────────────────
  Widget _buildScanTab() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Camera
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: MobileScanner(
                  controller: _scanController,
                  onDetect: (BarcodeCapture capture) {
                    for (final barcode in capture.barcodes) {
                      final code = barcode.rawValue;
                      if (code != null && code != _scannedCode) {
                        setState(() => _scannedCode = code);
                        break;
                      }
                    }
                  },
                ),
              ),

              // Corner bracket overlay
              Positioned.fill(
                child: CustomPaint(painter: _QRCornerPainter()),
              ),

              // Center label
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 160.h),
                    Text(
                      'Point camera at a QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 6)
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Flash toggle
              Positioned(
                top: 12.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () => _scanController.toggleTorch(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.flash_on,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanned result card
        if (_scannedCode != null)
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _kAccent.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scanned Result',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF8B9ABB),
                      letterSpacing: 1,
                    )),
                SizedBox(height: 6.h),
                Text(
                  _scannedCode!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _scanResultBtn(
                      icon: Icons.copy_outlined,
                      label: 'Copy',
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: _scannedCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied!')),
                        );
                      },
                    ),
                    SizedBox(width: 10.w),
                    _scanResultBtn(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () => Share.share(_scannedCode!),
                    ),
                    SizedBox(width: 10.w),
                    _scanResultBtn(
                      icon: Icons.close,
                      label: 'Clear',
                      onTap: () =>
                          setState(() => _scannedCode = null),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          SizedBox(height: 16.h),
      ],
    );
  }

  Widget _scanResultBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: _kElevated,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 14.sp),
              SizedBox(width: 4.w),
              Text(label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QRCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4361EE)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 32.0;
    final w = size.width;
    final h = size.height;
    const pad = 60.0;

    canvas.drawLine(Offset(pad, pad + len), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad), paint);
    canvas.drawLine(
        Offset(w - pad - len, pad), Offset(w - pad, pad), paint);
    canvas.drawLine(
        Offset(w - pad, pad), Offset(w - pad, pad + len), paint);
    canvas.drawLine(
        Offset(pad, h - pad - len), Offset(pad, h - pad), paint);
    canvas.drawLine(
        Offset(pad, h - pad), Offset(pad + len, h - pad), paint);
    canvas.drawLine(Offset(w - pad - len, h - pad),
        Offset(w - pad, h - pad), paint);
    canvas.drawLine(Offset(w - pad, h - pad - len),
        Offset(w - pad, h - pad), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
