import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service that abstracts the Nearby Connections plugin for both Android and iOS.
/// It provides simple methods to start/stop discovery, advertise, and send/receive payloads.
class NearbyService {
  static const _strategy = Strategy.P2P_CLUSTER;
  final Nearby _nearby = Nearby();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final StreamController<Endpoint> _discoveredController =
      StreamController.broadcast();
  final StreamController<String> _payloadReceivedController =
      StreamController.broadcast();

  Stream<Endpoint> get discoveredEndpoints => _discoveredController.stream;
  Stream<String> get payloadsReceived => _payloadReceivedController.stream;

  /// Initialize the plugin and request necessary permissions on the platform.
  Future<void> init() async {
    // Permissions are handled in AndroidManifest / Info.plist.
    // On iOS, the plugin internally requests Bluetooth & location permissions.
    await _nearby.init(_strategy);
  }

  /// Starts discovering nearby devices.
  Future<void> startDiscovery({required String userName}) async {
    await _nearby.startDiscovery(
      userName,
      _strategy,
      onEndpointFound: (Endpoint endpoint) {
        if (kDebugMode) {
          print('Discovered endpoint: ${endpoint.id} (${endpoint.name})');
        }
        _discoveredController.add(endpoint);
      },
      onEndpointLost: (Endpoint endpoint) {
        if (kDebugMode) {
          print('Lost endpoint: ${endpoint.id}');
        }
      },
    );
  }

  /// Stops discovery.
  Future<void> stopDiscovery() async => await _nearby.stopDiscovery();

  /// Starts advertising this device so others can discover it.
  Future<void> startAdvertising({required String userName}) async {
    await _nearby.startAdvertising(
      userName,
      _strategy,
      onConnectionInitiated: (id, info) async {
        // Auto-accept the connection for this demo.
        await _nearby.acceptConnection(id);
      },
      onConnectionResult: (id, status) {
        if (kDebugMode) {
          print('Connection $id result: $status');
        }
      },
      onDisconnected: (id) {
        if (kDebugMode) {
          print('Disconnected from $id');
        }
      },
    );
  }

  /// Stops advertising.
  Future<void> stopAdvertising() async => await _nearby.stopAdvertising();

  /// Sends a string payload to a connected endpoint.
  Future<void> sendPayload({required String endpointId, required String data}) async {
    final payload = Payload.bytes(data.codeUnits);
    await _nearby.sendPayload(endpointId, payload);
  }

  /// Listen for incoming payloads.
  Future<void> listenForPayloads() async {
    _nearby.payloadReceived.listen((payload) {
      if (payload.type == PayloadType.BYTES && payload.bytes != null) {
        final received = String.fromCharCodes(payload.bytes!);
        _payloadReceivedController.add(received);
      }
    });
  }

  /// Dispose streams when no longer needed.
  void dispose() {
    _discoveredController.close();
    _payloadReceivedController.close();
  }
}
