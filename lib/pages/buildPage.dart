//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_masterlink/models/euroMasterDevice.dart';
import 'package:flutter_masterlink/models/fs.dart';
import 'package:flutter_masterlink/models/jsonWorker.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_masterlink/utilites/colors.dart';
import 'package:flutter_masterlink/widgets/fsExplorer.dart';

class BuildPage extends StatefulWidget {
  @override
  _BuildPageState createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          appBar(context, 'Build'),
          deviceInfoBlock(context, false, ''),
          Expanded(child: FSExplorer())
        ],
      ),
    );
  }

  Widget appBar(BuildContext context, String title) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, size: 30)),
          Spacer(),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.folder,
                size: 30,
                color: Colors.yellow,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.upload,
                size: 30,
                color: Colors.green,
              )),
          //Download from device
          IconButton(
              onPressed: () async {
                MFolder newRoot =
                    await euroMasterDevice.getFSstructureFromDevice();
                JSONworker worker = JSONworker();
                await worker
                    .writeFile(worker.createFSstructure(newRoot.toMap()));
                setState(() {});
              },
              icon: Icon(
                Icons.download,
                size: 30,
                color: Colors.orange[400],
              )),
          //format device
          IconButton(
              onPressed: () async {
                await euroMasterDevice.formatDevice();
              },
              icon: Icon(
                Icons.delete,
                size: 30,
                color: Colors.purple,
              )),
          IconButton(onPressed: () {}, icon: Icon(Icons.share, size: 30)),
        ],
      ),
    );
  }

  Widget deviceInfoBlock(
      BuildContext context, bool connectionStatus, String deviceData) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
      child: Row(
        children: [
          Icon(Icons.devices, size: 30),
          Container(width: 20),
          Text(
              'Device: ' + (connectionStatus ? deviceData : 'No Device Paired'))
        ],
      ),
    );
  }
}
