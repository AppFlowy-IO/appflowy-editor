import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const bool _enableLog = false;

void activateLog() {
  if (!_enableLog) {
    return;
  }
  LogConfiguration()
    ..handler = debugPrint
    ..level = LogLevel.all;
}

void deactivateLog() {
  if (!_enableLog) {
    return;
  }
  LogConfiguration()
    ..handler = null
    ..level = LogLevel.off;
}
