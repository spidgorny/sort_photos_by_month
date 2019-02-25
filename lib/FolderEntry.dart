import 'dart:io';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

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
