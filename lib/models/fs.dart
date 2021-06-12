abstract class FSElement {
  final String name;
  FSElement(this.name);
}

class MFile extends FSElement {
  final String ext; //file extension like 'pdf', 'txt' etc.
  @override
  MFile(this.ext, name) : super(name);

  factory MFile.fromMap(Map<String, dynamic> map) {
    return MFile(map['ext'], map['name']);
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "ext": ext};
  }
}

class MFolder extends FSElement {
  List<MFolder> folders = [];
  List<MFile> files = [];

  MFolder(name, {this.folders = const [], this.files = const []}) : super(name);

  factory MFolder.fromMap(Map<String, dynamic> map) {
    return MFolder(map['name'],
        folders: foldersFromList(map['folders']),
        files: filesFromList(map['files']));
  }

  Map<String, dynamic> toMap() {
    List tFolders = [];
    List tFiles = [];
    //Conver folders to list of maps
    this.folders.forEach((folder) {
      tFolders.add(folder.toMap());
    });
    //Convert files to list of maps
    this.files.forEach((file) {
      tFiles.add(file.toMap());
    });
    return {"name": name, "folders": tFolders, "files": tFiles};
  }
}

List<MFolder> foldersFromList(List maps) {
  List<MFolder> folders = [];
  maps.forEach((map) {
    folders.add(MFolder.fromMap(map));
  });
  return folders;
}

List<MFile> filesFromList(List maps) {
  List<MFile> files = [];
  maps.forEach((map) {
    files.add(MFile.fromMap(map));
  });
  return files;
}
