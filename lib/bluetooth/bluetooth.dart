import 'package:flutter_masterlink/bluetooth/ble_bluetooth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

//Singleton class to present bluetooth instance
class Bluetooth {
  //Create needed instances
  FlutterReactiveBle? ble;
  BleScanner? scanner;
  BleLogger? logger;
  BleStatusMonitor? monitor;
  BleConnector? connector;
  BleInteractor? interactor;

  //CCreate class instance from private constructor
  static final Bluetooth _bluetooth = Bluetooth._internal();

  //Class instance getter
  static Bluetooth get instance => _bluetooth;

  //Private constructor
  Bluetooth._internal() {
    ble = FlutterReactiveBle();
    logger = BleLogger();
    scanner = BleScanner(ble: ble!, logMessage: logger!.addToLog);
    monitor = BleStatusMonitor(ble!);
    connector = BleConnector(ble: ble!, logMessage: logger!.addToLog);
    interactor = BleInteractor(
        bleDiscoverServices: ble!.discoverServices,
        readCharacteristic: ble!.readCharacteristic,
        writeWithoutResponse: ble!.writeCharacteristicWithoutResponse,
        writeWithResponse: ble!.writeCharacteristicWithResponse,
        subscribeToCharacteristic: ble!.subscribeToCharacteristic,
        logMessage: logger!.addToLog);
  }
}
