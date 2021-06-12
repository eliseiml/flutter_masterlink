import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_reactive_state.dart';
import 'dart:async';
import 'package:meta/meta.dart';

class BleScanner extends ReactiveState<BleScannerState> {
  final FlutterReactiveBle _ble;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController.broadcast();
  StreamSubscription? _subscription;
  final void Function(String message) _logMessage;
  List<DiscoveredDevice> _devices = [];

  BleScanner(
      {required FlutterReactiveBle ble,
      required Function(String message) logMessage})
      : _ble = ble,
        _logMessage = logMessage;

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  Future<void> startScan(List<Uuid> servicesToDiscover) async {
    _logMessage('Start ble scanning');
    _devices.clear();
    await _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: servicesToDiscover).listen((device) {
      final int knownDeviceIndex =
          _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      print('Found device: name: ${device.name}; id: ${device.id}');
      _pushState();
    }, onError: (Object e) => _logMessage('Ble scanning faild with: $e'));
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble scanning');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> autoScan(
      {Duration timeout = const Duration(seconds: 5),
      List<Uuid> servicesToDiscover = const []}) async {
    _logMessage('Ble autoScan started with duration ${timeout.inSeconds}s');
    await startScan(servicesToDiscover);
    await Future.delayed(timeout);
    await stopScan();
    _logMessage('Ble autoScan finished');
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }

  void _pushState() {
    _stateStreamController.add(BleScannerState(
        discoveredDevices: _devices, isScanning: _subscription != null));
  }
}

@immutable
class BleScannerState {
  final List<DiscoveredDevice> discoveredDevices;
  final bool isScanning;
  BleScannerState({required this.discoveredDevices, required this.isScanning});
}
