import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FilePickerResult {
  const FilePickerResult(this.files);

  /// Picked files.
  final List<PlatformFile> files;
}

/// Abstract file picker as a service to implement dependency injection.
abstract class FilePickerService {
  Future<String?> getDirectoryPath({
    String? title,
  }) async =>
      throw UnimplementedError('getDirectoryPath() has not been implemented.');

  /// The picked files' content is read on demand with
  /// [PlatformFile.readAsBytes] or [PlatformFile.readAsByteStream].
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowMultiple = false,
  }) async =>
      throw UnimplementedError('pickFiles() has not been implemented.');

  /// Saves [bytes] to a location chosen by the user and returns its [Uri], or
  /// `null` if the user cancels.
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    String? dialogTitle,
    String? initialDirectory,
  }) async =>
      throw UnimplementedError('saveFile() has not been implemented.');
}
