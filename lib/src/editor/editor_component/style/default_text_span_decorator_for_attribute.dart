import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Support Desktop and Web platform
///   - customize the href text span
TextSpan defaultTextSpanDecoratorForAttribute(
  BuildContext context,
  Node node,
  int index,
  TextInsert text,
  TextSpan before,
  TextSpan after,
) {
  final attributes = text.attributes;
  if (attributes == null) {
    return before;
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
      style: before.style,
      text: text.text,
      recognizer: tapGestureRecognizer,
    );
  }
  return before;
}
