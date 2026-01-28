// Stub file for web - provides empty File class
// This file is used when building for web to avoid dart:io dependency

class File {
  File(String path);

  Future<void> writeAsString(String contents) async {
    throw UnsupportedError('File operations are not supported on web');
  }

  Future<void> writeAsBytes(List<int> bytes) async {
    throw UnsupportedError('File operations are not supported on web');
  }

  Future<String> readAsString() async {
    throw UnsupportedError('File operations are not supported on web');
  }
}
