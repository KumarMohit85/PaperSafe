import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service that abstracts the Nearby Connections plugin for both Android and iOS.
/// It provides methods to start/stop discovery, advertise, and send/receive
/// payloads (both string and file). Streams expose discovered endpoints and
/// received payload data.
class NearbyService {
  static const _strategy = Strategy.P2P_CLUSTER;
  final Nearby _nearby = Nearby();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Streams for discovered endpoints and received payloads (string & file).
  final StreamController<Endpoint> _discoveredController =
      StreamController.broadcast();
  final StreamController<String> _stringPayloadController =
      StreamController.broadcast();
  final StreamController<FilePayload> _filePayloadController =
      StreamController.broadcast();

  Stream<Endpoint> get discoveredEndpoints => _discoveredController.stream;
  Stream<String> get stringPayloads => _stringPayloadController.stream;
  Stream<FilePayload> get filePayloads => _filePayloadController.stream;

  /// Initialize the plugin. Permissions are declared in AndroidManifest and
  /// Info.plist; the plugin will request Bluetooth & location on iOS.
  Future<void> init() async {
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

  /// Starts advertising this device.
  Future<void> startAdvertising({required String userName}) async {
    await _nearby.startAdvertising(
      userName,
      _strategy,
      onConnectionInitiated: (id, info) async {
        // Auto‑accept for demo purposes.
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

  /// Sends a string payload.
  Future<void> sendString({required String endpointId, required String data}) async {
    final payload = Payload.bytes(data.codeUnits);
    await _nearby.sendPayload(endpointId, payload);
  }

  /// Sends a single file payload.
  Future<void> sendFile({required String endpointId, required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    final payload = await Payload.file(filePath);
    await _nearby.sendPayload(endpointId, payload);
  }

  /// Sends multiple files sequentially.
  Future<void> sendMultipleFiles({required String endpointId, required List<String> filePaths}) async {
    for (final path in filePaths) {
      await sendFile(endpointId: endpointId, filePath: path);
    }
  }

  /// Listen for incoming payloads (string and file).
  Future<void> listenForPayloads() async {
    _nearby.payloadReceived.listen((payload) {
      if (payload.type == PayloadType.BYTES && payload.bytes != null) {
        final received = String.fromCharCodes(payload.bytes!);
        _stringPayloadController.add(received);
      } else if (payload.type == PayloadType.FILE && payload.file != null) {
        // The plugin provides a temporary file path.
        _filePayloadController.add(payload.file!);
      }
    });
  }

  /// Dispose resources.
  void dispose() {
    _discoveredController.close();
    _stringPayloadController.close();
    _filePayloadController.close();
  }
}

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
