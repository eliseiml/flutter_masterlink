import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_reactive_state.dart';

class BleConnector extends ReactiveState<ConnectionStateUpdate> {
  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final StreamController<ConnectionStateUpdate> _deviceConnectionController =
      StreamController.broadcast();
  DiscoveredDevice? connectedDevice;
  bool isNowConnected = false;

  BleConnector(
      {required FlutterReactiveBle ble,
      required Function(String message) logMessage})
      : _ble = ble,
        _logMessage = logMessage;

  late StreamSubscription<ConnectionStateUpdate> _subscription;

  Future<void> connect(DiscoveredDevice device,
      {Duration timeout = const Duration(seconds: 5)}) async {
    _logMessage('Try connect to the device ${device.id}');
    _subscription = _ble
        .connectToDevice(id: device.id, connectionTimeout: timeout)
        .listen((update) {
      _logMessage(
          'ConnectionState for device ${device.id} : ${update.connectionState}');
      _deviceConnectionController.add(update);
      if (update.connectionState == DeviceConnectionState.connected) {
        connectedDevice = device;
        isNowConnected = true;
      }
    },
            onError: (Object e) => _logMessage(
                'Connectiond to device ${device.id} failed with $e'));
  }

  Future<void> disconnect(DiscoveredDevice device) async {
    try {
      _logMessage('Try disconnect from device ${device.id}');
      await _subscription.cancel();
    } on Exception catch (e, _) {
      _logMessage('Diconnection from ${device.id} failed: $e');
    } finally {
      _deviceConnectionController.add(ConnectionStateUpdate(
          deviceId: device.id,
          connectionState: DeviceConnectionState.disconnected,
          failure: null));
      connectedDevice = null;
      isNowConnected = false;
    }
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;
}
