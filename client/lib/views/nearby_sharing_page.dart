import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:papersafe/core/services/nearby_service.dart';
import 'package:papersafe/Widgets/endpoint_card.dart';

const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kGreen = Color(0xFF22C55E);
const _kCircle = Color(0xFF1A2D4A);

final nearbyServiceProvider = Provider<NearbyService>((ref) {
  return NearbyService();
});

// Mock transfer history entries
const _mockHistory = [
  (file: 'Aadhaar Card.pdf', meta: '1.2 MB → Priya\'s iPhone', time: '10:24 AM'),
  (file: 'Flight ticket.pdf', meta: '860 KB → Karthik\'s Pixel', time: 'Yesterday'),
];

// Mock nearby devices
const _mockDevices = [
  (name: 'Priya\'s iPhone', dist: '2 m away', icon: Icons.phone_iphone_rounded),
  (name: 'Office MacBook', dist: '5 m away', icon: Icons.laptop_mac_rounded),
  (name: 'Karthik\'s Pixel', dist: '8 m away', icon: Icons.phone_android_rounded),
];

class NearbySharingPage extends ConsumerStatefulWidget {
  const NearbySharingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NearbySharingPage> createState() => _NearbySharingPageState();
}

class _NearbySharingPageState extends ConsumerState<NearbySharingPage> {
  late final NearbyService _service;
  bool _broadcasting = false;
  NearbyDevice? _selectedEndpoint;
  List<String> _selectedFiles = [];
  bool _isConnecting = false;
  String? _connectingTo;

  @override
  void initState() {
    super.initState();
    _service = ref.read(nearbyServiceProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    await _service.init();
    _service.discoveredEndpoints.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.stopDiscovery();
    _service.stopAdvertising();
    _service.dispose();
    super.dispose();
  }

  Future<void> _toggleBroadcasting(bool value) async {
    setState(() => _broadcasting = value);
    if (value) {
      await _service.startDiscovery(userName: 'PaperSafeUser');
    } else {
      await _service.stopDiscovery();
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _sendFiles() async {
    if (_selectedEndpoint == null || _selectedFiles.isEmpty) return;
    await _service.sendMultipleFiles(
      endpointId: _selectedEndpoint!.id,
      filePaths: _selectedFiles,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Files sent successfully')),
      );
    }
  }

  Future<void> _mockConnect(String deviceName) async {
    setState(() {
      _isConnecting = true;
      _connectingTo = deviceName;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _connectingTo = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $deviceName')),
      );
    }
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
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCircle.withOpacity(0.7),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEARBY SHARE',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: const Color(0xFF8B9ABB),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Share securely',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Encrypted, offline transfer to devices near you.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF8B9ABB),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Broadcasting card ───────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.white10),
                        ),
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Wifi icon badge
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: _kElevated,
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.wifi_rounded,
                                    color: Color(0xFF8B9ABB),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Broadcasting',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Visible as "Arjun\'s device"',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color:
                                              const Color(0xFF8B9ABB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.85,
                                  child: Switch(
                                    value: _broadcasting,
                                    onChanged: _toggleBroadcasting,
                                    activeColor: _kGreen,
                                    activeTrackColor:
                                        _kGreen.withOpacity(0.3),
                                    inactiveThumbColor:
                                        const Color(0xFF8B9ABB),
                                    inactiveTrackColor:
                                        Colors.white12,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),
                            const Divider(color: Colors.white10, height: 1),
                            SizedBox(height: 12.h),

                            // Info tags row
                            Row(
                              children: [
                                _infoTag(
                                    Icons.lock_outline, 'End-to-end encrypted'),
                                SizedBox(width: 12.w),
                                _infoTag(Icons.bluetooth_rounded,
                                    'BLE + Wi-Fi Direct'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Nearby devices section ──────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby devices',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {}),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius:
                                    BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Icon(Icons.refresh_rounded,
                                  color: Color(0xFF8B9ABB), size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Mock device list
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: _mockDevices.map((device) {
                          final isConnecting = _isConnecting &&
                              _connectingTo == device.name;
                          return _deviceCard(
                            name: device.name,
                            distance: device.dist,
                            icon: device.icon,
                            isConnecting: isConnecting,
                            onConnect: () => _mockConnect(device.name),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Transfer history ────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Transfer history',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: _mockHistory.map((item) {
                          return _historyItem(
                            fileName: item.file,
                            meta: item.meta,
                            time: item.time,
                          );
                        }).toList(),
                      ),
                    ),

                    // File picker + send row (if files selected)
                    if (_selectedFiles.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.attach_file,
                                    size: 18),
                                label: Text(
                                    '${_selectedFiles.length} file(s) selected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kSurface,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            ElevatedButton.icon(
                              onPressed: _sendFiles,
                              icon: const Icon(Icons.send, size: 18),
                              label: const Text('Send'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GestureDetector(
                          onTap: _pickFiles,
                          child: Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: _kSurface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: _kAccent.withOpacity(0.3),
                                  style: BorderStyle.solid),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_file,
                                    color: _kAccent, size: 18.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Pick files to send',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: _kAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF8B9ABB), size: 13),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF8B9ABB),
          ),
        ),
      ],
    );
  }

  Widget _deviceCard({
    required String name,
    required String distance,
    required IconData icon,
    required bool isConnecting,
    required VoidCallback onConnect,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: _kElevated,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF8B9ABB), size: 22),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text(distance,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF8B9ABB),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: isConnecting ? null : onConnect,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isConnecting
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyItem({
    required String fileName,
    required String meta,
    required String time,
  }) {
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
            child: const Icon(Icons.description_outlined,
                color: Color(0xFF8B9ABB), size: 16),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text(meta,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B9ABB),
                    )),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF8B9ABB),
              )),
        ],
      ),
    );
  }
}
