import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

(TextDirection, String?) getNodeDirection(
  Node node, [
  String? lastStartText,
  TextDirection? lastDirection,
  FlowyTextDirection defaultDirection = FlowyTextDirection.ltr,
]) {
  final text = node.delta?.toPlainText();
  final FlowyTextDirection direction =
      node.attributes.direction ?? defaultDirection;
  TextDirection fallBackDir = direction == FlowyTextDirection.rtl
      ? TextDirection.rtl
      : TextDirection.ltr;
  fallBackDir = lastDirection ?? fallBackDir;

  final prevNodeDir = node
      .previousNodeWhere((n) => n.selectable != null)
      ?.selectable!
      .textDirection();
  if (direction == FlowyTextDirection.auto && prevNodeDir != null) {
    fallBackDir = lastDirection ?? prevNodeDir;
  }
  if (direction != FlowyTextDirection.auto || (text?.isEmpty ?? true)) {
    return (fallBackDir, null);
  }

  if (lastStartText != null &&
      lastDirection != null &&
      text!.startsWith(lastStartText)) {
    return (lastDirection, lastStartText);
  }

  final RegExp regex = RegExp(
    r"(?:([\p{sc=Arabic}\p{sc=Hebrew}\p{sc=Syriac}\p{sc=Thaana}])|([0-9\p{sc=Armenian}\p{sc=Bengali}\p{sc=Bopomofo}\p{sc=Braille}\p{sc=Buhid}\p{sc=Canadian_Aboriginal}\p{sc=Cherokee}\p{sc=Cyrillic}\p{sc=Devanagari}\p{sc=Ethiopic}\p{sc=Georgian}\p{sc=Greek}\p{sc=Gujarati}\p{sc=Gurmukhi}\p{sc=Han}\p{sc=Hangul}\p{sc=Hanunoo}\p{sc=Hiragana}\p{sc=Inherited}\p{sc=Kannada}\p{sc=Katakana}\p{sc=Khmer}\p{sc=Lao}\p{sc=Latin}\p{sc=Limbu}\p{sc=Malayalam}\p{sc=Mongolian}\p{sc=Myanmar}\p{sc=Ogham}\p{sc=Oriya}\p{sc=Runic}\p{sc=Sinhala}\p{sc=Tagalog}\p{sc=Tagbanwa}\p{sc=Tamil}\p{sc=Telugu}\p{sc=Thai}\p{sc=Tibetan}\p{sc=Yi}]))",
    unicode: true,
  );
  final match = regex.firstMatch(text!);
  if (match?[1] != null) {
    return (TextDirection.rtl, text.substring(0, match!.end));
  } else if (match?[2] != null) {
    return (TextDirection.ltr, text.substring(0, match!.end));
  }

  return (fallBackDir, null);
}
