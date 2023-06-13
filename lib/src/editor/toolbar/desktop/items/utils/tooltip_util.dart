import 'dart:io';

import 'package:flutter/foundation.dart';

String shortcutTooltips(
  String? macOSString,
  String? windowsString,
  String? linuxString,
) {
  if (kIsWeb) return '';
  if (Platform.isMacOS && macOSString != null) {
    return '\n$macOSString';
  } else if (Platform.isWindows && windowsString != null) {
    return '\n$windowsString';
  } else if (Platform.isLinux && linuxString != null) {
    return '\n$linuxString';
  }
  return '';
}
