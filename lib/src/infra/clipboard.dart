import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

class AppFlowyClipboardData {
  const AppFlowyClipboardData({
    this.text,
    this.html,
  });
  final String? text;
  final String? html;
}

class AppFlowyClipboard {
  static AppFlowyClipboardData? _mockData;

  static Future<void> setData({
    String? text,
    String? html,
  }) async {
    // https://github.com/BringingFire/rich_clipboard/issues/13
    // Wrapping a `<html><body>` tag for html in Windows,
    //  otherwise it will raise an exception
    if (!kIsWeb && Platform.isWindows && html != null) {
      if (!html.startsWith('<html><body>')) {
        html = '<html><body>$html</body></html>';
      }
    }

    return RichClipboard.setData(
      RichClipboardData(
        text: text,
        html: html,
      ),
    );
  }

  static Future<AppFlowyClipboardData> getData() async {
    if (_mockData != null) {
      return _mockData!;
    }

    final data = await RichClipboard.getData();
    final text = data.text;
    var html = data.html;

    // https://github.com/BringingFire/rich_clipboard/issues/13
    // Remove all the fragment symbol in Windows.
    if (!kIsWeb && Platform.isWindows && html != null) {
      html = html
          .replaceAll('<!--StartFragment-->', '')
          .replaceAll('<!--EndFragment-->', '');
    }

    return AppFlowyClipboardData(
      text: text,
      html: html,
    );
  }

  @visibleForTesting
  static void mockSetData(AppFlowyClipboardData? data) {
    _mockData = data;
  }
}
