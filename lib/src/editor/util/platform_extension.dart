import 'dart:io';

import 'package:flutter/foundation.dart';

// TODO(Xazin): Refactor to honor `Theme.platform`
extension PlatformExtension on Platform {
  static bool get isMacOS {
    if (kIsWeb) {
      return false;
    }
    return Platform.isMacOS;
  }

  static bool get isWindows {
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows;
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
