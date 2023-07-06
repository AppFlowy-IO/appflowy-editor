import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The style of the editor.
///
/// You can customize the style of the editor by passing the [EditorStyle] to
///  the [AppFlowyEditor].
///
class EditorStyle {
  const EditorStyle({
    required this.padding,
    required this.cursorColor,
    required this.selectionColor,
    required this.textStyleConfiguration,
    required this.textSpanDecorator,
  });

  /// The padding of the editor.
  final EdgeInsets padding;

  /// The cursor color
  final Color cursorColor;

  /// The selection color
  final Color selectionColor;

  /// Customize the text style of the editor.
  ///
  /// All the text-based components will use this configuration to build their
  ///   text style.
  ///
  /// Notes, this configuration is only for the common config of text style and
  ///   it maybe override if the text block has its own [BlockComponentConfiguration].
  final TextStyleConfiguration textStyleConfiguration;

  /// Customize the built-in or custom text span.
  ///
  /// For example, you can add a custom text span for the mention text
  ///   or override the built-in text span.
  final TextSpanDecoratorForAttribute? textSpanDecorator;

  const EditorStyle.desktop({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 100),
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor: selectionColor ?? const Color(0xFFE0F8FF),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator:
              textSpanDecorator ?? defaultTextSpanDecoratorForAttribute,
        );

  const EditorStyle.mobile({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor:
              selectionColor ?? const Color.fromARGB(53, 111, 201, 231),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator: textSpanDecorator,
        );

  EditorStyle copyWith({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) {
    return EditorStyle(
      padding: padding ?? this.padding,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyleConfiguration:
          textStyleConfiguration ?? this.textStyleConfiguration,
      textSpanDecorator: textSpanDecorator ?? this.textSpanDecorator,
    );
  }
}

/// Supports
///
///   - customize the href text span
TextSpan defaultTextSpanDecoratorForAttribute(
  BuildContext context,
  Node node,
  int index,
  TextInsert text,
  TextSpan textSpan,
) {
  final attributes = text.attributes;
  if (attributes == null) {
    return textSpan;
  }
  final editorState = context.read<EditorState>();
  final href = attributes[AppFlowyRichTextKeys.href] as String?;
  if (href != null) {
    // add a tap gesture recognizer to the text span
    Timer? timer;
    int tapCount = 0;
    final tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // implement a simple double tap logic
        tapCount += 1;
        timer?.cancel();
        if (tapCount == 2 || !editorState.editable) {
          tapCount = 0;
          safeLaunchUrl(href);
          return;
        }
        timer = Timer(const Duration(milliseconds: 200), () {
          tapCount = 0;
          final selection = Selection.single(
            path: node.path,
            startOffset: index,
            endOffset: index + text.text.length,
          );
          editorState.updateSelectionWithReason(
            selection,
            reason: SelectionUpdateReason.uiEvent,
          );
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showLinkMenu(context, editorState, selection, true);
          });
        });
      };
    return TextSpan(
      style: textSpan.style,
      text: text.text,
      recognizer: tapGestureRecognizer,
    );
  }
  return textSpan;
}
