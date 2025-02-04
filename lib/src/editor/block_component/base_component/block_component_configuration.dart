import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

typedef BlockComponentTextStyleBuilder = TextStyle Function(
  Node node, {
  TextSpan? textSpan,
});

/// only for the common config of block component
class BlockComponentConfiguration {
  const BlockComponentConfiguration({
    this.padding = _padding,
    this.indentPadding = _indentPadding,
    this.placeholderText = _placeholderText,
    this.textStyle = _textStyle,
    this.placeholderTextStyle = _placeholderTextStyle,
    this.blockSelectionAreaMargin = _blockSelectionAreaPadding,
    this.textAlign = _textAlign,
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
  final BlockComponentTextStyleBuilder textStyle;

  /// The placeholder text of a block component.
  final String Function(Node node) placeholderText;

  /// The placeholder text style of a block component.
  ///
  /// It inherits the style from [textStyle].
  final BlockComponentTextStyleBuilder placeholderTextStyle;

  /// The padding of a block selection area.
  final EdgeInsets Function(Node node) blockSelectionAreaMargin;

  /// The text align of a block component.
  ///
  /// This value is only available for the block with text,
  /// e.g. paragraph, heading, quote, to-do list, bulleted list, numbered list
  final TextAlign Function(Node node) textAlign;

  BlockComponentConfiguration copyWith({
    EdgeInsets Function(Node node)? padding,
    BlockComponentTextStyleBuilder? textStyle,
    String Function(Node node)? placeholderText,
    BlockComponentTextStyleBuilder? placeholderTextStyle,
    EdgeInsets Function(Node node)? blockSelectionAreaMargin,
    TextAlign Function(Node node)? textAlign,
    EdgeInsets Function(Node node, TextDirection textDirection)? indentPadding,
  }) {
    return BlockComponentConfiguration(
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      placeholderText: placeholderText ?? this.placeholderText,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      blockSelectionAreaMargin:
          blockSelectionAreaMargin ?? this.blockSelectionAreaMargin,
      textAlign: textAlign ?? this.textAlign,
      indentPadding: indentPadding ?? this.indentPadding,
    );
  }
}

mixin BlockComponentConfigurable<T extends StatefulWidget> on State<T> {
  BlockComponentConfiguration get configuration;
  Node get node;

  EdgeInsets get padding => configuration.padding(node);

  TextStyle textStyleWithTextSpan({TextSpan? textSpan}) =>
      configuration.textStyle(node, textSpan: textSpan);

  TextStyle placeholderTextStyleWithTextSpan({TextSpan? textSpan}) =>
      configuration.placeholderTextStyle(node, textSpan: textSpan);

  String get placeholderText => configuration.placeholderText(node);

  TextAlign get textAlign => configuration.textAlign(node);
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

TextStyle _textStyle(Node node, {TextSpan? textSpan}) {
  return const TextStyle();
}

String _placeholderText(Node node) {
  return ' ';
}

TextStyle _placeholderTextStyle(Node node, {TextSpan? textSpan}) {
  return const TextStyle(
    color: Colors.grey,
  );
}

EdgeInsets _blockSelectionAreaPadding(Node node) {
  return const EdgeInsets.symmetric(vertical: 0.0);
}

TextAlign _textAlign(Node node) {
  return TextAlign.start;
}
