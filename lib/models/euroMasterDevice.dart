import 'dart:async';
import 'dart:convert';
import 'package:flutter_masterlink/bluetooth/ble_bluetooth.dart';
import '../bluetooth/ble_bluetooth.dart';
import '../utilites/constants.dart';
import 'fs.dart';

class EuroMasterDevice {
  Future<bool> checkConditions() async {
    bool connected = Bluetooth.instance.connector!.isNowConnected;
    if (connected != true) {
      print('connector.isNowConnected = false. Operation terminated');
      return false;
    } else if (Bluetooth.instance.connector!.connectedDevice == null) {
      print('connector.connectedDevice = null. Operation terminated');
      return false;
    } else {
      List<DiscoveredService> services = await Bluetooth.instance.interactor!
          .descoverServices(Bluetooth.instance.connector!.connectedDevice!.id);
      print('Discovered services: ${services.length}');
      if (!services
          .any((service) => service.serviceId == Uuid.parse(sppService))) {
        print(
            "connectedDevice doesn't discover sppService. Operation terminated");
        return false;
      }
    }
    return true;
  }

  Future<void> formatDevice() async {
    bool conditions = await checkConditions();
    if (!conditions) {
      print('Wrong conditions. Format terminated');
      return;
    }
    String deviceID = Bluetooth.instance.connector!.connectedDevice!.id;
    try {
      await Bluetooth.instance.interactor!.writeCharacterisiticWithoutResponse(
          QualifiedCharacteristic(
              characteristicId: Uuid.parse(sppCharacteristic),
              serviceId: Uuid.parse(sppService),
              deviceId: deviceID),
          ascii.encode(format));
    } on Exception catch (e) {
      print('Error when format device: $e');
    }
  }

  late StreamSubscription<List<int>> _subscription;
  bool subscribedToSpp = false;

  Future<void> _subscribeToSpp() async {
    responseInt.clear();
    responseStr = '';
    String deviceID = Bluetooth.instance.connector!.connectedDevice!.id;
    _subscription = Bluetooth.instance.interactor!
        .subScribeToCharacteristic(QualifiedCharacteristic(
            characteristicId: Uuid.parse(sppCharacteristic),
            serviceId: Uuid.parse(sppService),
            deviceId: deviceID))
        .listen(
      (update) {
        _onSppResponse(update);
      },
    );
    subscribedToSpp = true;
    print('SUBSCRIBED');
  }

  Future<void> _unsubscribeFromSpp() async {
    await _subscription.cancel();
    print('UNSUBSCRIBED');
    subscribedToSpp = false;
  }

  List<int> responseInt = [];
  String responseStr = '';
  bool readingDataFromDevice = false;

  void _onSppResponse(List<int> snapshot) {
    String response = ascii.decode(snapshot, allowInvalid: true);
    responseInt.addAll(snapshot);
    responseStr += response;
    if (responseStr.contains(end)) {
      _unsubscribeFromSpp();
      print("WHOLE RESULT:\n $responseStr");
      readingDataFromDevice = false;
    }
  }

  Future<void> getMemList() async {
    bool conditions = await checkConditions();
    if (!conditions) {
      print('Wrong conditions. Format terminated');
      return;
    }
    String deviceID = Bluetooth.instance.connector!.connectedDevice!.id;

    if (!subscribedToSpp) _subscribeToSpp();
    try {
      await Bluetooth.instance.interactor!.writeCharacterisiticWithResponse(
          QualifiedCharacteristic(
              characteristicId: Uuid.parse(sppCharacteristic),
              serviceId: Uuid.parse(sppService),
              deviceId: deviceID),
          ascii.encode(get_mem_list));
      readingDataFromDevice = true;
    } on Exception catch (e) {
      print('Error when getting memlist: $e');
      readingDataFromDevice = false;
    }
  }

  //Data layer contract

  MFolder defaultRoot = MFolder('Root', folders: [], files: []);

  Future<MFolder> getFSstructureFromDevice() async {
    MFolder root = MFolder('', folders: [], files: []);
    //1. Request data from the device
    await getMemList();
    await Future.delayed(Duration(seconds: 2));
    String data = responseStr;
    //2. Decode received data to MFolder type
    /* 
    /folder1
    /folder1/file2_
    /folder2
    /folder2/file3_
    /defaultPATH
    /file1_
    --End-- 
    */
    if (data.isEmpty) return defaultRoot;
    List<String> items = data.split('\r\n');
    //remove blank field '\r\n'
    items.removeLast();
    List<String> folders = [];
    List<String> files = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i] == end + ' ') {
        continue;
      }
      if (items[i] == '/defaultPATH') {
        continue;
      }
      if (items[i].endsWith(file_identificator)) {
        files.add(items[i]);
      } else {
        folders.add(items[i]);
      }
    }
    /*
    folders: ['/folder1', '/folder2', '/folder2/folder22', '/folder1/folder11/folder111']
    files:   ['/folder1/file2_', '/folder2/file3_', '/file1_']
    */
    root = parseNodefromStr(root, folders, files);
    return root;
  }

  MFolder parseNodefromStr(
      MFolder node, List<String> folders, List<String> files) {
    //Find nested folders of the current node
    List<String> currNodeFolders = [];
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].startsWith(node.name + '/')) {
        String path = folders[i].substring(node.name.length + 1);
        if (!path.contains('/')) {
          currNodeFolders.add(path);
          folders.removeAt(i);
          i--;
        } else {
          folders[i] = path;
        }
      }
    }
    //Find nested files of the current node
    List<String> currNodeFiles = [];
    for (int i = 0; i < files.length; i++) {
      if (files[i].startsWith(node.name + '/')) {
        String path = files[i].substring(node.name.length + 1);
        if (!path.contains('/')) {
          currNodeFiles.add(path);
          files.removeAt(i);
          i--;
        } else {
          files[i] = path;
        }
      }
    }
    /*
      currNodeFolders: ['folder1', 'folder2']
      currNodeFiles:   ['file1_']
      folders:         ['folder2/folder22', 'folder1/folder11/folder111']
      files:           ['folder1/file2_', 'folder2/file3_']
      */
    currNodeFiles.forEach((file) {
      node.files.add(MFile('file', file));
    });
    currNodeFolders.forEach((folder) {
      node.folders.add(parseNodefromStr(
          MFolder(folder, folders: [], files: []), folders, files));
    });
    return node;
  }
}

//currNodeFiles.map((e) => MFile('file', e)).toList()
EuroMasterDevice euroMasterDevice = EuroMasterDevice();
