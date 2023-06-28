import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

Image imageFromBase64String(String base64String, {double? width}) {
  return Image.memory(
    base64Decode(base64String),
    width: width,
  );
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

Future<String> base64StringFromImage(String imagePath) async {
  final file = File(imagePath); //convert Path to File
  final imageBytes = await file.readAsBytes(); //convert to bytes
  return base64.encode(imageBytes);
}
