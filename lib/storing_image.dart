import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageStorage{
  static Future<String> getExternalDocumentPath() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      _directory = Directory("/storage/emulated/0/DCIM/Screenshots");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    // final directory = await getApplicationDocumentsDirectory();
    // return directory.path;
    // To get the external path from device of download folder
    final String directory = await getExternalDocumentPath();
    return directory;
  }
  static Future<String> saveImage(Uint8List imageData, String fileName) async {
    final path = await _localPath;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'image_$timestamp.png';
    final file = File('$path/$fileName');
    await file.writeAsBytes(imageData);
    return file.path;
  }

  static Future<String> getExternalDocumentPath_screens() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      _directory = Directory("/storage/emulated/0/Pictures/Screenshots");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath_screens async {
    // final directory = await getApplicationDocumentsDirectory();
    // return directory.path;
    // To get the external path from device of download folder
    final String directory = await getExternalDocumentPath_screens();
    return directory;
  }
  static Future<String> saveImage_screens(Uint8List imageData, String fileName) async {
    final path = await _localPath_screens;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'image_$timestamp.jpg';
    final file = File('$path/$fileName');
    await file.writeAsBytes(imageData);
    OpenFilex.open(file.path);
    return file.path;
  }

}