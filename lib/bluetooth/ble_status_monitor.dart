import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_reactive_state.dart';

class BleStatusMonitor extends ReactiveState<BleStatus?> {
  final FlutterReactiveBle _ble;

  BleStatusMonitor(this._ble);

  @override
  Stream<BleStatus?> get state => _ble.statusStream;
}
