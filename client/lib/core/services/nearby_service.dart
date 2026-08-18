import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

class NearbyDevice {
  final String id;
  final String name;

  NearbyDevice({required this.id, required this.name});
}

/// Service that abstracts the Nearby Connections plugin for both Android and iOS.
class NearbyService {
  static const _strategy = Strategy.P2P_CLUSTER;
  final Nearby _nearby = Nearby();

  final StreamController<NearbyDevice> _discoveredController =
      StreamController.broadcast();
  final StreamController<String> _stringPayloadController =
      StreamController.broadcast();
  final StreamController<String> _filePayloadController =
      StreamController.broadcast();

  Stream<NearbyDevice> get discoveredEndpoints => _discoveredController.stream;
  Stream<String> get stringPayloads => _stringPayloadController.stream;
  Stream<String> get filePayloads => _filePayloadController.stream;

  Future<void> init() async {
    // NearbyConnections permissions
  }

  /// Starts discovering nearby devices.
  Future<void> startDiscovery({required String userName}) async {
    await _nearby.startDiscovery(
      userName,
      _strategy,
      onEndpointFound: (String id, String name, String serviceId) {
        if (kDebugMode) {
          print('Discovered endpoint: $id ($name)');
        }
        _discoveredController.add(NearbyDevice(id: id, name: name));
      },
      onEndpointLost: (String? id) {
        if (kDebugMode) {
          print('Lost endpoint: $id');
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
      onConnectionInitiated: (String id, ConnectionInfo info) async {
        await _nearby.acceptConnection(
          id,
          onPayLoadRecieved: (String endpointId, Payload payload) {
            if (payload.type == PayloadType.BYTES && payload.bytes != null) {
              final received = String.fromCharCodes(payload.bytes!);
              _stringPayloadController.add(received);
            } else if (payload.type == PayloadType.FILE && payload.filePath != null) {
              _filePayloadController.add(payload.filePath!);
            }
          },
        );
      },
      onConnectionResult: (String id, Status status) {
        if (kDebugMode) {
          print('Connection $id result: $status');
        }
      },
      onDisconnected: (String id) {
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
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(data.codeUnits));
  }

  /// Sends a single file payload.
  Future<void> sendFile({required String endpointId, required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    await _nearby.sendFilePayload(endpointId, filePath);
  }

  /// Sends multiple files sequentially.
  Future<void> sendMultipleFiles({required String endpointId, required List<String> filePaths}) async {
    for (final path in filePaths) {
      await sendFile(endpointId: endpointId, filePath: path);
    }
  }

  /// Dispose resources.
  void dispose() {
    _discoveredController.close();
    _stringPayloadController.close();
    _filePayloadController.close();
  }
}
