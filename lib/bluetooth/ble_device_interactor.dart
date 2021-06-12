import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleInteractor {
  final Future<List<DiscoveredService>> Function(String deviceID)
      _bleDiscoverServices;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      _readCharacteristic;
  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithoutResponse;
  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithResponse;
  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      _subscribeToCharacteristic;
  final void Function(String message) _logMessage;

  BleInteractor(
      {required Future<List<DiscoveredService>> Function(String deviceID)
          bleDiscoverServices,
      required Future<List<int>> Function(
              QualifiedCharacteristic characteristic)
          readCharacteristic,
      required Future<void> Function(QualifiedCharacteristic characteristic,
              {required List<int> value})
          writeWithoutResponse,
      required Future<void> Function(QualifiedCharacteristic characteristic,
              {required List<int> value})
          writeWithResponse,
      required Stream<List<int>> Function(
              QualifiedCharacteristic characteristic)
          subscribeToCharacteristic,
      required void Function(String message) logMessage})
      : _bleDiscoverServices = bleDiscoverServices,
        _readCharacteristic = readCharacteristic,
        _writeWithoutResponse = writeWithoutResponse,
        _writeWithResponse = writeWithResponse,
        _subscribeToCharacteristic = subscribeToCharacteristic,
        _logMessage = logMessage;

  Future<List<DiscoveredService>> descoverServices(String deviceID) async {
    try {
      _logMessage('Ble discovering services for $deviceID');
      final result = await _bleDiscoverServices(deviceID);
      _logMessage('Discovering services finished');
      return result;
    } on Exception catch (e) {
      _logMessage('Error occured when discovering services: $e');
      rethrow;
    }
  }

  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      final result = await _readCharacteristic(characteristic);

      _logMessage('Read ${characteristic.characteristicId}, value = $result');
      return result;
    } on Exception catch (e, s) {
      _logMessage(
          'Error occured when reading ${characteristic.characteristicId} : $e');
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacterisiticWithResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      _logMessage(
          'Write with response value : $value to ${characteristic.characteristicId}');
      await _writeWithResponse(characteristic, value: value);
    } on Exception catch (e, s) {
      _logMessage(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacterisiticWithoutResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _writeWithoutResponse(characteristic, value: value);
      _logMessage(
          'Write without response value: $value to ${characteristic.characteristicId}');
    } on Exception catch (e, s) {
      _logMessage(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      print(s);
      rethrow;
    }
  }

  Stream<List<int>> subScribeToCharacteristic(
      QualifiedCharacteristic characteristic) {
    _logMessage('Subscribing to: ${characteristic.characteristicId} ');
    return _subscribeToCharacteristic(characteristic);
  }
}
