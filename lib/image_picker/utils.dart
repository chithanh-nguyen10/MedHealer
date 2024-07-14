
import 'dart:typed_data';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tinyhealer/global.dart' as globals;

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file!= null) {
    final int fileSizeInBytes = await _file.length();
    final double fileSizeInMB = fileSizeInBytes / 1024.0 / 1024.0;
    globals.imageMB = fileSizeInMB;
    Uint8List imageBytes = await _file.readAsBytes();
    Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 800,
      minHeight: 800,
      quality: 100,
    );
    print(globals.imageMB);
    // ignore: unnecessary_null_comparison
    if (compressedBytes != null){
      globals.imageMB = compressedBytes.length / 1024.0 / 1024.0;
      print(globals.imageMB);
      imageBytes = compressedBytes;
    }
    return imageBytes;
  }
  print("No image selected!");
}
//2803