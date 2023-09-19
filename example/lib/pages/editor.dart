import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/desktop_editor.dart';
import 'package:example/pages/mobile_editor.dart';
import 'package:flutter/material.dart';

class Editor extends StatelessWidget {
  const Editor({
    super.key,
    required this.jsonString,
    required this.onEditorStateChange,
    this.editorStyle,
    this.textDirection = TextDirection.ltr,
  });

  final Future<String> jsonString;
  final EditorStyle? editorStyle;
  final void Function(EditorState editorState) onEditorStateChange;

  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<String>(
        future: jsonString,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            final editorState = EditorState(
              document: Document.fromJson(
                Map<String, Object>.from(
                  json.decode(snapshot.data!),
                ),
              ),
            );

            editorState.logConfiguration
              ..handler = debugPrint
              ..level = LogLevel.off;

            editorState.transactionStream.listen((event) {
              if (event.$1 == TransactionTime.after) {
                onEditorStateChange(editorState);
              }
            });

            if (PlatformExtension.isDesktopOrWeb) {
              return DesktopEditor(
                editorState: editorState,
                textDirection: textDirection,
              );
            } else if (PlatformExtension.isMobile) {
              return MobileEditor(
                editorState: editorState,
              );
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
