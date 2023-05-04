import 'package:flutter/material.dart';

/// only for the common config of text style
class TextStyleConfiguration {
  const TextStyleConfiguration({
    this.text = const TextStyle(fontSize: 16.0),
    this.bold = const TextStyle(fontWeight: FontWeight.bold),
    this.italic = const TextStyle(fontStyle: FontStyle.italic),
    this.underline = const TextStyle(
      decoration: TextDecoration.underline,
    ),
    this.strikethrough = const TextStyle(
      decoration: TextDecoration.lineThrough,
    ),
    this.href = const TextStyle(
      color: Colors.lightBlue,
      decoration: TextDecoration.underline,
    ),
    this.code = const TextStyle(
      color: Colors.red,
      backgroundColor: Color.fromARGB(98, 0, 195, 255),
    ),
  });

  final TextStyle text;
  final TextStyle bold;
  final TextStyle italic;
  final TextStyle underline;
  final TextStyle strikethrough;
  final TextStyle href;
  final TextStyle code;

  TextStyleConfiguration copyWith({
    TextStyle? text,
    TextStyle? bold,
    TextStyle? italic,
    TextStyle? underline,
    TextStyle? strikethrough,
    TextStyle? href,
    TextStyle? code,
  }) {
    return TextStyleConfiguration(
      text: text ?? this.text,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      href: href ?? this.href,
      code: code ?? this.code,
    );
  }
}
