import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// This regular expression matches either a single character from specific RTL (right-to-left) script categories or a digit or character from various other script categories.
/// It can be useful for identifying or manipulating text with mixed directional properties.
final _regex = RegExp(
  r"(?:([\p{sc=Arabic}\p{sc=Hebrew}\p{sc=Syriac}\p{sc=Thaana}])|([0-9\p{sc=Armenian}\p{sc=Bengali}\p{sc=Bopomofo}\p{sc=Braille}\p{sc=Buhid}\p{sc=Canadian_Aboriginal}\p{sc=Cherokee}\p{sc=Cyrillic}\p{sc=Devanagari}\p{sc=Ethiopic}\p{sc=Georgian}\p{sc=Greek}\p{sc=Gujarati}\p{sc=Gurmukhi}\p{sc=Han}\p{sc=Hangul}\p{sc=Hanunoo}\p{sc=Hiragana}\p{sc=Inherited}\p{sc=Kannada}\p{sc=Katakana}\p{sc=Khmer}\p{sc=Lao}\p{sc=Latin}\p{sc=Limbu}\p{sc=Malayalam}\p{sc=Mongolian}\p{sc=Myanmar}\p{sc=Ogham}\p{sc=Oriya}\p{sc=Runic}\p{sc=Sinhala}\p{sc=Tagalog}\p{sc=Tagbanwa}\p{sc=Tamil}\p{sc=Telugu}\p{sc=Thai}\p{sc=Tibetan}\p{sc=Yi}]))",
  unicode: true,
);

mixin BlockComponentTextDirectionMixin {
  Node get node;

  /// Calculate the text direction of a block component.
  TextDirection calculateTextDirection({
    TextDirection? defaultTextDirection,
  }) {
    defaultTextDirection = defaultTextDirection ?? TextDirection.ltr;
    // if the block component has a text direction attribute, use it
    final value = node.attributes[blockComponentTextDirection] as String?;
    if (value != null && value != blockComponentTextDirectionAuto) {
      return value.toTextDirection(fallback: defaultTextDirection);
    }

    // if the block component doesn't has a text direction attribute, but has a
    //  parent, use the text direction of the parent
    final previousNodeContainsTextDirection = node.previousNodeWhere(
      (element) => element.attributes.containsKey(blockComponentTextDirection),
    );
    if (value == blockComponentTextDirectionAuto &&
        previousNodeContainsTextDirection != null) {
      final String previousValue = previousNodeContainsTextDirection
          .attributes[blockComponentTextDirection];
      defaultTextDirection =
          previousValue.toTextDirection(fallback: defaultTextDirection);
    }

    // if the value isn't auto or the text is null or empty,
    //  use the default text direction
    final text = node.delta?.toPlainText();
    if (value != blockComponentTextDirectionAuto ||
        text == null ||
        text.isEmpty) {
      return defaultTextDirection;
    }

    // if the value is auto and the text isn't null or empty,
    //  calculate the text direction by the text
    final matches = _regex.firstMatch(text);
    if (matches != null) {
      if (matches.group(1) != null) {
        return TextDirection.rtl;
      } else if (matches.group(2) != null) {
        return TextDirection.ltr;
      }
    }

    return defaultTextDirection;
  }
}

extension on String {
  TextDirection toTextDirection({required TextDirection fallback}) {
    if (this == blockComponentTextDirectionLTR) {
      return TextDirection.ltr;
    } else if (this == blockComponentTextDirectionRTL) {
      return TextDirection.rtl;
    }
    return fallback;
  }
}
