import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// only for the common config of block component
class BlockComponentConfiguration {
  const BlockComponentConfiguration({
    this.padding = _padding,
    this.indentPadding = _indentPadding,
    this.placeholderText = _placeholderText,
    this.textStyle = _textStyle,
    this.placeholderTextStyle = _placeholderTextStyle,
  });

  /// The padding of a block component.
  ///
  /// It works only for the block component itself, not for the children.
  final EdgeInsets Function(Node node) padding;

  /// The padding of a block component.
  ///
  /// It works only for the block that needs to be indented.
  final EdgeInsets Function(
    Node node,
    TextDirection textDirection,
  ) indentPadding;

  /// The text style of a block component.
  final TextStyle Function(Node node) textStyle;

  /// The placeholder text of a block component.
  final String Function(Node node) placeholderText;

  /// The placeholder text style of a block component.
  ///
  /// It inherits the style from [textStyle].
  final TextStyle Function(Node node) placeholderTextStyle;

  BlockComponentConfiguration copyWith({
    EdgeInsets Function(Node node)? padding,
    TextStyle Function(Node node)? textStyle,
    String Function(Node node)? placeholderText,
    TextStyle Function(Node node)? placeholderTextStyle,
  }) {
    return BlockComponentConfiguration(
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      placeholderText: placeholderText ?? this.placeholderText,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
    );
  }
}

mixin BlockComponentConfigurable<T extends StatefulWidget> on State<T> {
  BlockComponentConfiguration get configuration;
  Node get node;

  EdgeInsets get padding => configuration.padding(node);

  TextStyle get textStyle => configuration.textStyle(node);

  String get placeholderText => configuration.placeholderText(node);

  TextStyle get placeholderTextStyle =>
      configuration.placeholderTextStyle(node);
}

EdgeInsets _padding(Node node) {
  return const EdgeInsets.symmetric(vertical: 4.0);
}

EdgeInsets _indentPadding(Node node, TextDirection textDirection) {
  switch (textDirection) {
    case TextDirection.ltr:
      return const EdgeInsets.only(left: 24.0);
    case TextDirection.rtl:
      return const EdgeInsets.only(right: 24.0);
  }
}

TextStyle _textStyle(Node node) {
  return const TextStyle();
}

String _placeholderText(Node node) {
  return ' ';
}

TextStyle _placeholderTextStyle(Node node) {
  return const TextStyle(
    color: Colors.grey,
  );
}
