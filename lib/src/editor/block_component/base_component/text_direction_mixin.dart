import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// This regular expression matches either a single character from specific RTL (right-to-left) script categories or a digit or character from various other script categories.
/// It can be useful for identifying or manipulating text with mixed directional properties.
final _regex = RegExp(
  r"(?:([\p{sc=Arabic}\p{sc=Hebrew}\p{sc=Syriac}\p{sc=Thaana}])|([0-9\p{sc=Armenian}\p{sc=Bengali}\p{sc=Bopomofo}\p{sc=Braille}\p{sc=Buhid}\p{sc=Canadian_Aboriginal}\p{sc=Cherokee}\p{sc=Cyrillic}\p{sc=Devanagari}\p{sc=Ethiopic}\p{sc=Georgian}\p{sc=Greek}\p{sc=Gujarati}\p{sc=Gurmukhi}\p{sc=Han}\p{sc=Hangul}\p{sc=Hanunoo}\p{sc=Hiragana}\p{sc=Inherited}\p{sc=Kannada}\p{sc=Katakana}\p{sc=Khmer}\p{sc=Lao}\p{sc=Latin}\p{sc=Limbu}\p{sc=Malayalam}\p{sc=Mongolian}\p{sc=Myanmar}\p{sc=Ogham}\p{sc=Oriya}\p{sc=Runic}\p{sc=Sinhala}\p{sc=Tagalog}\p{sc=Tagbanwa}\p{sc=Tamil}\p{sc=Telugu}\p{sc=Thai}\p{sc=Tibetan}\p{sc=Yi}]))",
  unicode: true,
);

mixin BlockComponentTextDirectionMixin {
  EditorState get editorState;
  Node get node;

  TextDirection? lastDirection;

  /// Calculate the text direction of a block component.
  // defaultTextDirection will be ltr if caller hasn't passed any value.
  TextDirection calculateTextDirection({TextDirection? layoutDirection}) {
    layoutDirection ??= TextDirection.ltr;
    final defaultTextDirection = editorState.editorStyle.defaultTextDirection;

    final direction = calculateNodeDirection(
      node: node,
      layoutDirection: layoutDirection,
      defaultTextDirection: defaultTextDirection,
      lastDirection: lastDirection,
    );

    // node indent padding is added by parent node and the padding direction
    // is equal to the node text direction. when the node direction is auto
    // there is a special case which on typing text, the node direction could
    // change without any change to parent node, because no attribute of the
    // node changes as the direction attribute is auto but the calculated can
    // change to rtl or ltr. in this cases we should notify parent node to
    // recalculate the indent padding.
    if (node.level > 1 &&
        direction != lastDirection &&
        node.direction(defaultTextDirection) ==
            blockComponentTextDirectionAuto) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => node.parent?.notify());
    }
    lastDirection = direction;

    return direction;
  }
}

/// Calculate the text direction of a node.
// If the textDirection attribute is not set, we will use defaultTextDirection if
// it has a value (defaultTextDirection != null). If not will use layoutDirection.
// If the textDirection is ltr or rtl we will apply that.
// If the textDirection is auto we go by these priorities:
// 1. Determine the direction by first character with strong directionality
// 2. lastDirection which is the node last determined direction
// 3. previous line direction
// 4. defaultTextDirection
// 5. layoutDirection
// We will move from first priority when for example the node text is empty or
// it only has characters without strong directionality e.g. '@'.
TextDirection calculateNodeDirection({
  required Node node,
  required TextDirection layoutDirection,
  String? defaultTextDirection,
  TextDirection? lastDirection,
}) {
  // if the block component has a text direction attribute which is not auto,
  // use it
  final value = node.direction(defaultTextDirection);
  if (value != null && value != blockComponentTextDirectionAuto) {
    final direction = value.toTextDirection();
    if (direction != null) {
      return direction;
    }
  }

  if (value == blockComponentTextDirectionAuto) {
    if (lastDirection != null) {
      defaultTextDirection = lastDirection.name;
    } else {
      defaultTextDirection =
          _getDirectionFromPreviousOrParentNode(node, defaultTextDirection)
                  ?.name ??
              defaultTextDirection;
    }
  }

  // if the value is null or the text is null or empty,
  // use the default text direction
  final text = node.delta?.toPlainText();
  if (value == null || text == null || text.isEmpty) {
    return defaultTextDirection?.toTextDirection() ?? layoutDirection;
  }

  // if the value is auto and the text isn't null or empty,
  // calculate the text direction by the text
  return _determineTextDirection(text) ??
      defaultTextDirection?.toTextDirection() ??
      layoutDirection;
}

TextDirection? _getDirectionFromPreviousOrParentNode(
  Node node,
  String? defaultTextDirection,
) {
  TextDirection? prevOrParentNodeDirection;
  if (node.previous != null) {
    prevOrParentNodeDirection = _getDirectionFromNode(
      node.previous!,
      defaultTextDirection,
    );
  }
  if (node.parent != null && prevOrParentNodeDirection == null) {
    prevOrParentNodeDirection = _getDirectionFromNode(
      node.parent!,
      defaultTextDirection,
    );
  }
  return prevOrParentNodeDirection;
}

TextDirection? _getDirectionFromNode(Node node, String? defaultTextDirection) {
  final nodeDirection = node.direction(
    defaultTextDirection == blockComponentTextDirectionAuto
        ? blockComponentTextDirectionAuto
        : null,
  );
  if (nodeDirection == blockComponentTextDirectionAuto) {
    return node.selectable?.textDirection();
  } else {
    return nodeDirection?.toTextDirection();
  }
}

TextDirection? _determineTextDirection(String text) {
  final matches = _regex.firstMatch(text);
  if (matches != null) {
    if (matches.group(1) != null) {
      return TextDirection.rtl;
    } else if (matches.group(2) != null) {
      return TextDirection.ltr;
    }
  }
  return null;
}

extension on Node {
  String? direction(String? defaultDirection) =>
      attributes[blockComponentTextDirection] as String? ?? defaultDirection;
}

extension on String {
  TextDirection? toTextDirection() {
    if (this == blockComponentTextDirectionLTR) {
      return TextDirection.ltr;
    } else if (this == blockComponentTextDirectionRTL) {
      return TextDirection.rtl;
    }
    return null;
  }
}
