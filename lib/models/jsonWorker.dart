import 'dart:convert';
import 'package:flutter_masterlink/models/fs.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class JSONworker {
  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    //return 'data/user/0/com.example.flutter_masterlink/app_flutter';
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/data.json');
  }

  Future<File> writeFile(String data) async {
    final file = await _localFile();

    // Write the file
    return file.writeAsString(data);
  }

  Future<String> readFile() async {
    try {
      final file = await _localFile();

      // Read the file
      if (await file.exists()) {
        final contents = await file.readAsString();
        return contents;
      } else {
        await writeFile(createFSstructure(defaultRoot.toMap()));
        await readFile();
      }
    } catch (e) {
      throw 'Error reading file';
    }
    return createFSstructure(defaultRoot.toMap());
  }

  MFolder defaultRoot = MFolder('Root', folders: [], files: []);

  MFolder? rootFolder;
  //Reads the data.json file from the app's documents directory and converts it to
  //appropriate List type
  Future<MFolder> getFSstructure() async {
    MFolder root;
    //1. Read data from file to the String
    String json = await readFile();
    //2. Decode json string to Map<String, dynamic>
    Map<String, dynamic> map = jsonDecode(json);
    //3. Convert Map to MFoler type
    root = MFolder.fromMap(map);
    return root;
  }

  String createFSstructure(Map<String, dynamic> fs) {
    String json = '';
    json = jsonEncode(fs);
    print(json);
    return json;
  }
}
