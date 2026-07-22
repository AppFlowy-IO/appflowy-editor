import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  @visibleForTesting
  static String? lastText;

  // In-process rich-content fallback.
  //
  // Flutter's system `Clipboard` only carries `text/plain`, so the rich `html`
  // computed on copy was previously dropped on the floor (`setData` ignored it
  // and `getData` hard-coded `html: null`). With no html, the paste handler
  // skips its formatting-preserving `pasteHtml` branch and falls back to a
  // bare, attribute-less plain-text delta — so a copy→paste of formatted text
  // (bold/italic/lists/etc.) lost ALL formatting, even within this same app.
  //
  // We retain the last copied html here and hand it back on `getData` ONLY when
  // the system clipboard still holds the exact text we last wrote — i.e. this
  // is a same-app copy→paste round trip. If another app replaced the clipboard,
  // the text won't match and we correctly return `html: null` (plain paste),
  // so external plain-text paste still degrades gracefully.
  static String? _lastHtml;

  static Future<void> setData({
    String? text,
    String? html,
  }) async {
    if (text == null) {
      return;
    }

    lastText = text;
    _lastHtml = html;

    return Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
  }

  static Future<AppFlowyClipboardData> getData() async {
    if (_mockData != null) {
      return _mockData!;
    }

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final systemText = data?.text;

    // Reattach the retained html only for a same-app copy→paste round trip
    // (system clipboard text still equals what we last copied). Otherwise the
    // clipboard was replaced externally → return plain (html: null).
    final html =
        (_lastHtml != null && systemText != null && systemText == lastText)
            ? _lastHtml
            : null;

    return AppFlowyClipboardData(
      text: systemText,
      html: html,
    );
  }

  @visibleForTesting
  static void mockSetData(AppFlowyClipboardData? data) {
    _mockData = data;
  }
}
