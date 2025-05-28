import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;
import 'package:universal_platform/universal_platform.dart';

// TODO(Xazin): Refactor to honor `Theme.platform`
extension PlatformExtension on Platform {
  static String get _webPlatform =>
      window.navigator.platform?.toLowerCase() ?? '';

  /// Returns true if the operating system is macOS and not running on Web platform.
  static bool get isMacOS => UniversalPlatform.isMacOS;

  /// Returns true if the operating system is Windows and not running on Web platform.
  static bool get isWindows => UniversalPlatform.isWindows;

  /// Returns true if the operating system is Linux and not running on Web platform.
  static bool get isLinux => UniversalPlatform.isLinux;

  /// Returns true if the operating system is iOS and not running on Web platform.
  static bool get isIOS => UniversalPlatform.isIOS;

  /// Returns true if the operating system is Android and not running on Web platform.
  static bool get isAndroid => UniversalPlatform.isAndroid;

  /// Returns true if the operating system is macOS and running on Web platform.
  static bool get isWebOnMacOS {
    if (!kIsWeb) {
      return false;
    }
    return _webPlatform.contains('mac') == true;
  }

  /// Returns true if the operating system is Windows and running on Web platform.
  static bool get isWebOnWindows {
    if (!kIsWeb) {
      return false;
    }
    return _webPlatform.contains('windows') == true;
  }

  /// Returns true if the operating system is Linux and running on Web platform.
  static bool get isWebOnLinux {
    if (!kIsWeb) {
      return false;
    }
    return _webPlatform.contains('linux') == true;
  }

  static bool get isDesktopOrWeb =>
      UniversalPlatform.isWeb || UniversalPlatform.isDesktop;

  static bool get isDesktop => UniversalPlatform.isDesktop;

  static bool get isMobile => UniversalPlatform.isMobile;

  static bool get isNotMobile => !isMobile;
}
