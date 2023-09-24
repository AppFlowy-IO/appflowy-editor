import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;

// TODO(Xazin): Refactor to honor `Theme.platform`
extension PlatformExtension on Platform {
  static String get _webPlatform =>
      window.navigator.platform?.toLowerCase() ?? '';

  /// Returns true if the operating system is macOS and not running on Web platform.
  static bool get isMacOS {
    if (kIsWeb) {
      return false;
    }
    return Platform.isMacOS;
  }

  /// Returns true if the operating system is Windows and not running on Web platform.
  static bool get isWindows {
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows;
  }

  /// Returns true if the operating system is Linux and not running on Web platform.
  static bool get isLinux {
    if (kIsWeb) {
      return false;
    }
    return Platform.isLinux;
  }

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

  static bool get isDesktopOrWeb {
    if (kIsWeb) {
      return true;
    }
    return isDesktop;
  }

  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool get isMobile {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isNotMobile {
    if (kIsWeb) {
      return false;
    }
    return !isMobile;
  }
}
