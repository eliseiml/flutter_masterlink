//@dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_masterlink/models/jsonWorker.dart';
import 'package:flutter_masterlink/utilites/colors.dart';
import '../models/fs.dart';

class FSExplorer extends StatefulWidget {
  @override
  _FSExplorerState createState() => _FSExplorerState();
}

class _FSExplorerState extends State<FSExplorer> {
  MFolder root;
  MFolder head;
  JSONworker jsonWorker = JSONworker();
  List<MFolder> prevPtrs = [];
  int builds = 0;

  Future<void> _getRootFolder() async {
    if (builds == 0) {
      root = await jsonWorker.getFSstructure();
      head = root;
    }
    builds++;
  }

  Widget getCurrentView() {
    List<Widget> list = [];
    String currentPath = root.name + ':/';
    prevPtrs.forEach((element) {
      if (element != root) currentPath += '/' + element.name;
    });
    if (head != root) currentPath += '/' + head.name;
    list.add(pathBlock(context, currentPath));
    if (head != root) list.add(goUpButton(context));
    head.folders.forEach((folder) {
      list.add(folderView(context, folder));
    });
    head.files.forEach((file) {
      list.add(fileView(context, file));
    });
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        });
  }

  String newName = '';
  TextEditingController _controller = TextEditingController();
  Future<void> _showNewNameDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter folder/file name'),
          content: TextFormField(
            controller: _controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                newName = _controller.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
            child: FutureBuilder(
                future: _getRootFolder(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.connectionState == ConnectionState.done &&
                      root != null) {
                    return getCurrentView();
                  }
                  return Center(child: Text('An ERROR has been occured.'));
                })),
        fab(context, fabExpanded)
      ],
    );
  }

  Widget folderView(BuildContext context, MFolder folder) {
    return GestureDetector(
      onTap: () {
        setState(() {
          prevPtrs.add(head);
          head = folder;
        });
      },
      onLongPress: () {
        head.folders.removeAt(head.folders.indexOf(folder));
        setState(() {});
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 50,
        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
        child: Row(
          children: [
            Icon(Icons.folder, size: 30, color: Colors.yellow),
            Container(width: 20),
            Text(folder.name)
          ],
        ),
      ),
    );
  }

  Widget fileView(BuildContext context, MFile file) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 50,
        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
        child: Row(
          children: [
            Icon(Icons.file_copy, size: 30),
            Container(width: 20),
            Text(file.name + '.' + file.ext)
          ],
        ),
      ),
    );
  }

  Widget goUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          head = prevPtrs[prevPtrs.length - 1] ?? root;
          prevPtrs.removeLast();
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 50,
        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 30),
            Container(width: 20),
            Text('. . .')
          ],
        ),
      ),
    );
  }

  Widget pathBlock(BuildContext context, String path) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kAccentColor, width: 0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text(path)],
      ),
    );
  }

  bool fabExpanded = false;
  Widget fab(BuildContext context, bool isExpanded) {
    return Container(
      height: 170,
      width: 50,
      //alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(right: 20, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isExpanded
              ? //button create FOLDER
              Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                      onPressed: () async {
                        await _showNewNameDialog();
                        if (newName.isNotEmpty) {
                          head.folders
                              .add(MFolder(newName, folders: [], files: []));
                          newName = '';
                          _controller.clear();
                          await jsonWorker.writeFile(
                              jsonWorker.createFSstructure(root.toMap()));
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.create_new_folder,
                        color: kBackgroundColor,
                        size: 30,
                      )),
                )
              : Container(),
          isExpanded
              ? //button create FILE
              Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                      onPressed: () async {
                        await _showNewNameDialog();
                        if (newName.isNotEmpty) {
                          head.files.add(MFile('ext', newName));
                          newName = '';
                          _controller.clear();
                          await jsonWorker.writeFile(
                              jsonWorker.createFSstructure(root.toMap()));
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.document_scanner,
                        color: kBackgroundColor,
                        size: 30,
                      )),
                )
              : Container(),
          GestureDetector(
            onTap: () {
              setState(() {
                fabExpanded = !fabExpanded;
              });
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Icon(
                Icons.add,
                color: kBackgroundColor,
                size: 30,
              ),
            ),
          )
        ],
      ),
    );
  }
}
