/* import 'dart:convert';
import 'package:flutter_masterlink/bluetooth/ble_bluetooth.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  final BluetoothDevice device;
  const ServicesPage(this.device, {Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState(device);
}

class _ServicesPageState extends State<ServicesPage> {
  final BluetoothDevice device;
  _ServicesPageState(this.device);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<BluetoothService>>(
          stream: Stream.fromFuture(device.discoverServices()),
          initialData: [],
          builder: (context, snapshot) {
            return Column(
              children: snapshot.data!.map((s) => ServiceTile(s)).toList(),
            );
          },
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  const ServiceTile(this.service, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.grey,
      child: Column(
        children: [
          Text('Device ID: ${service.deviceId.id}'),
          Divider(),
          Text('Service UUID:'),
          Text(service.uuid.toString()),
          Divider(),
          Text(service.isPrimary ? 'PRIMARY' : 'NON PRIMAPRY'),
          Divider(),
          Text('Characteristics: '),
          Column(
            children: service.characteristics
                .map((c) => CharacteristicTile(c))
                .toList(),
          ),
          Divider(),
          Text('Included services'),
          Column(
            children:
                service.includedServices.map((s) => ServiceTile(s)).toList(),
          )
        ],
      ),
    );
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  const CharacteristicTile(this.characteristic, {Key? key}) : super(key: key);

  @override
  _CharacteristicTileState createState() =>
      _CharacteristicTileState(characteristic);
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  final BluetoothCharacteristic characteristic;
  _CharacteristicTileState(this.characteristic);
  List<int> char = [];
  Future<void> _readChar() async {
    if (characteristic.properties.read) {
      char = await characteristic.read();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[200],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text('Char UUID:'),
          Text(characteristic.uuid.toString()),
          Text('Property read: ${characteristic.properties.read}'),
          Text('Property write: ${characteristic.properties.write}'),
          Text('Value:'),
          ElevatedButton(onPressed: _readChar, child: Text('Read')),
          Text(char.toString()),
          Text(ascii.decode(char, allowInvalid: true))
        ],
      ),
    );
  }
}

/* class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  CharacteristicTile(this.characteristic, {Key? key}) : super(key: key);
  List<int> char = [];
  Future<void> _readChar() async {
    char = await characteristic.read();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Char UUID:'),
          Text(characteristic.uuid.toString()),
          Text('Value:'),
          ElevatedButton(onPressed: _readChar, child: Text('Read')),
          Text(char.toString()),
        ],
      ),
    );
  }
} */
 */
