import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

void activateLog() {
  LogConfiguration()
    ..handler = debugPrint
    ..level = LogLevel.all;
}

void deactivateLog() {
  LogConfiguration()
    ..handler = null
    ..level = LogLevel.off;
}
