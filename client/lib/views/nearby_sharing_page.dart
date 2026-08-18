import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:papersafe/core/services/nearby_service.dart';
import 'package:papersafe/Widgets/endpoint_card.dart';

final nearbyServiceProvider = Provider<NearbyService>((ref) {
  return NearbyService();
});

/// Premium UI for nearby file sharing.
class NearbySharingPage extends ConsumerStatefulWidget {
  const NearbySharingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NearbySharingPage> createState() => _NearbySharingPageState();
}

class _NearbySharingPageState extends ConsumerState<NearbySharingPage> {
  late final NearbyService _service;
  bool _discoveryOn = false;
  NearbyDevice? _selectedEndpoint;
  List<String> _selectedFiles = [];

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

  Future<void> _toggleDiscovery(bool value) async {
    setState(() => _discoveryOn = value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Sharing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Glass‑morphism background.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discovery', style: TextStyle(color: Colors.white, fontSize: 18)),
                      Switch(
                        value: _discoveryOn,
                        onChanged: _toggleDiscovery,
                        activeColor: Colors.tealAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Discovered Devices', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<NearbyDevice>(
                      stream: _service.discoveredEndpoints,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: Text('No devices found. Toggle discovery ON to search.', style: TextStyle(color: Colors.white70)));
                        }
                        final endpoint = snapshot.data!;
                        return ListView(
                          children: [
                            EndpointCard(
                              endpoint: endpoint,
                              selected: _selectedEndpoint?.id == endpoint.id,
                              onTap: () => setState(() => _selectedEndpoint = endpoint),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Pick Files'),
                        onPressed: _pickFiles,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                        onPressed: _sendFiles,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                      ),
                    ],
                  ),
                  if (_selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Selected: ${_selectedFiles.length} file(s)', style: const TextStyle(color: Colors.white70)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
