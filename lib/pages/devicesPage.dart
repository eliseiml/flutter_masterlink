import 'package:flutter/material.dart';
import 'package:flutter_masterlink/utilites/colors.dart';
import 'package:flutter_masterlink/widgets/appBar.dart';
import 'package:flutter_masterlink/bluetooth/ble_bluetooth.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<BleScannerState>(
        stream: Bluetooth.instance.scanner!.state,
        initialData: BleScannerState(discoveredDevices: [], isScanning: false),
        builder: (context, snapshot) {
          return Column(
            children: [
              appBar(context, 'Devices'),
              scanButton(context, snapshot),
              Text('Connected device:', style: TextStyle(fontSize: 16)),
              if (Bluetooth.instance.connector!.isNowConnected)
                DeviceTile(Bluetooth.instance.connector!.connectedDevice!),
              Expanded(
                  child: SingleChildScrollView(
                      child: devicesList(context, snapshot)))
            ],
          );
        },
      ),
    );
  }

  Widget scanButton(
      BuildContext context, AsyncSnapshot<BleScannerState> snapshot) {
    return GestureDetector(
      onTap: () {
        if (snapshot.data!.isScanning)
          Bluetooth.instance.scanner!.stopScan();
        else
          Bluetooth.instance.scanner!.autoScan();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 180,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
                snapshot.data!.isScanning
                    ? Icons.bluetooth_searching
                    : Icons.bluetooth_connected,
                color:
                    snapshot.data!.isScanning ? kActiveColor : kBackgroundColor,
                size: 30),
            Text(snapshot.data!.isScanning ? 'Stop scanning' : 'Start scanning',
                style: TextStyle(color: kBackgroundColor))
          ],
        ),
      ),
    );
  }

  Widget devicesList(
      BuildContext context, AsyncSnapshot<BleScannerState> snapshot) {
    //column(connected devices, scan results) ToDo
    return Column(
      children: [
        Container(
            height: 50,
            alignment: Alignment.center,
            child: Text('Search result:', style: TextStyle(fontSize: 16))),
        //Scan result
        Column(
            children: snapshot.data!.discoveredDevices
                .map((r) => DeviceTile(r))
                .toList())
      ],
    );
  }
}

class DeviceTile extends StatefulWidget {
  final DiscoveredDevice device;
  const DeviceTile(this.device, {Key? key}) : super(key: key);

  @override
  _DeviceTileState createState() => _DeviceTileState(device);
}

class _DeviceTileState extends State<DeviceTile> {
  final DiscoveredDevice device;
  _DeviceTileState(this.device);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStateUpdate>(
      stream: Bluetooth.instance.connector!.state,
      initialData: ConnectionStateUpdate(
          deviceId: device.id,
          connectionState: DeviceConnectionState.disconnected,
          failure: null),
      builder: (context, state) {
        AsyncSnapshot<ConnectionStateUpdate> snapshot = AsyncSnapshot.withData(
            ConnectionState.none,
            ConnectionStateUpdate(
                deviceId: this.device.id,
                connectionState: DeviceConnectionState.disconnected,
                failure: null));
        if (this.device.id == state.data!.deviceId) {
          snapshot = state;
        } else if (Bluetooth.instance.connector!.isNowConnected) {
          if (device.id == Bluetooth.instance.connector!.connectedDevice!.id) {
            snapshot = AsyncSnapshot.withData(
                ConnectionState.done,
                ConnectionStateUpdate(
                    deviceId: this.device.id,
                    connectionState: DeviceConnectionState.connected,
                    failure: null));
          }
        }
        return GestureDetector(
          onTap: () async {
            if (snapshot.data!.connectionState ==
                DeviceConnectionState.disconnected) {
              await Bluetooth.instance.connector!.connect(device);
            }
          },
          onLongPress: () {
            if (snapshot.data!.connectionState ==
                DeviceConnectionState.connected)
              Bluetooth.instance.connector!.disconnect(device);
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: kAccentColor, width: 0.2))),
            child: Row(
              children: [
                Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Icon(Icons.bluetooth_rounded,
                        size: 40,
                        color: snapshot.data!.connectionState ==
                                DeviceConnectionState.connected
                            ? Colors.green
                            : kAccentColor)),
                Container(width: 20),
                Expanded(
                  child: Text(
                      device.name != ''
                          ? device.name
                          : 'N/A, rssi:${device.rssi}',
                      style: TextStyle(
                          fontSize: 16,
                          color: snapshot.data!.connectionState ==
                                  DeviceConnectionState.connected
                              ? Colors.green
                              : Colors.white)),
                ),
                (snapshot.data!.connectionState ==
                            DeviceConnectionState.connecting ||
                        snapshot.data!.connectionState ==
                            DeviceConnectionState.disconnecting)
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kAccentColor))
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
