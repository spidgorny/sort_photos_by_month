import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:permission/permission.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sort photos by month',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Sort photos by month'),
    );
  }
}

class FolderEntry {
  final FileSystemEntity folder;
  int photos;
  int videos;
  int rest;
  VoidCallback update;

  FolderEntry(this.folder, {@required this.update}) {
    startFileCounter();
  }

  void startFileCounter() {
    //var files = (folder as Directory).listSync();
    var dir = Directory(folder.path);
    photos = 0;
    videos = 0;
    rest = 0;
    dir.list().listen((FileSystemEntity f) {
      var mime = lookupMimeType(f.path);
      if (mime?.startsWith('video') ?? false) {
        videos++;
      } else if (mime?.startsWith('image') ?? false) {
        photos++;
      } else {
        rest++;
      }
    }).onDone(() {
      update();
    });
  }

  String get fileName {
    var path = folder.path.split('/');
    var fileName = path.last;
    return fileName;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Directory camera = Directory('/storage/emulated/0/DCIM/Camera');
  List<FolderEntry> dirs = [];
  bool permissionGranted = false;
  FolderEntry root;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    List<Permissions> permissions =
        await Permission.getPermissionsStatus([PermissionName.Storage]);
    validatePermissionStatus(permissions);
  }

  void validatePermissionStatus(List<Permissions> permissions) {
    print(permissions);
    for (var p in permissions) {
      if (p.permissionName == PermissionName.Storage) {
        print([p.permissionName, p.permissionStatus]);
        if (p.permissionStatus == PermissionStatus.allow) {
          setState(() {
            permissionGranted = true;
            readFiles();
          });
        }
      }
    }
  }

  void readFiles() async {
    dirs.clear();
    root = FolderEntry(camera, update: () => setState(() {}));
    Stream<FileSystemEntity> _photoList = camera.list();
    _photoList.listen((FileSystemEntity f) {
      if (f.statSync().type == FileSystemEntityType.directory) {
        setState(() {
          this.dirs.add(FolderEntry(f, update: () => setState(() {})));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: permissionGranted
          ? Column(children: [
              renderHeader(context),
              Expanded(child: renderListView(context))
            ])
          : Center(
              child: RaisedButton(
              child: Text('Allow reading camera folder'),
              onPressed: () async {
                List<Permissions> permissionNames =
                    await Permission.requestPermissions(
                        [PermissionName.Storage]);
                validatePermissionStatus(permissionNames);
              },
            )),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this.readFiles();
        },
        tooltip: 'Increment',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget renderHeader(BuildContext context) {
    return ListTile(
      title: Text(camera.path),
      leading: Icon(Icons.camera),
      subtitle: Text('Photos: ${root.photos}, Videos: ${root.videos}'),
      trailing: RaisedButton(
        child: Text('Move by month'),
        onPressed: () {
          moveFilesByMonth();
        },
      ),
    );
  }

  Widget renderListView(BuildContext context) {
    dirs.sort((f1, f2) => f2.fileName.compareTo(f1.fileName));
    return dirs.length > 0
        ? ListView(
            shrinkWrap: true,
            children: dirs.map((f) {
              return ListTile(
                dense: true,
                title: Text(f.fileName),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Chip(label: Text(f.photos.toString())),
                  Chip(
                    label: Text(f.videos.toString()),
                  )
                ]),
              );
            }).toList(),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  void moveFilesByMonth() {
    var dir = Directory(root.folder.path);
    var files = dir.listSync();
    for (var f in files) {
      if (f is File) {
        var mime = lookupMimeType(f.path);
        if (mime != null) {
          if (mime.startsWith('video') || mime.startsWith('image')) {
            var date = f.statSync().modified;
            var Ym = date.year.toString() +
                '-' +
                date.month.toString().padLeft(2, '0');
            print([Ym, date, f.path.split('/').last]);
          }
        }
      }
    }
  }
}
