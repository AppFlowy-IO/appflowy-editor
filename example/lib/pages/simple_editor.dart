import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SimpleEditor extends StatelessWidget {
  const SimpleEditor({
    super.key,
    required this.jsonString,
    required this.themeData,
    required this.onEditorStateChange,
  });

  final Future<String> jsonString;
  final ThemeData themeData;
  final void Function(EditorState editorState) onEditorStateChange;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
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
            ..level = LogLevel.all;
          onEditorStateChange(editorState);
          if (PlatformExtension.isDesktopOrWeb) {
            return FloatingToolbar(
                editorState: editorState,
                child: _buildEditor(context, editorState));
          } else {
            return Column(
              children: [
                Expanded(child: _buildEditor(context, editorState)),
                if (Platform.isIOS || Platform.isAndroid)
                  _buildMobileToolbar(context, editorState),
              ],
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildEditor(BuildContext context, EditorState editorState) {
    return AppFlowyEditor(
      editorState: editorState,
      themeData: themeData,
      autoFocus: editorState.document.isEmpty,
      // customBuilders: {
      //   'paragraph': TextBlockComponentBuilder(),
      //   'todo_list': TodoListBlockComponentBuilder(),
      //   'bulleted_list': BulletedListBlockComponentBuilder(),
      //   'numbered_list': NumberedListBlockComponentBuilder(),
      //   'quote': QuoteBlockComponentBuilder(),
      // },
      blockComponentBuilders: {
        'document': DocumentComponentBuilder(),
        'paragraph': TextBlockComponentBuilder(),
        'todo_list': TodoListBlockComponentBuilder(),
        'bulleted_list': BulletedListBlockComponentBuilder(),
        'numbered_list': NumberedListBlockComponentBuilder(),
        'quote': QuoteBlockComponentBuilder(),
      },
      characterShortcutEvents: [
        // '\n'
        insertNewLine,

        // bulleted list
        formatAsteriskToBulletedList,
        formatMinusToBulletedList,

        // slash
        slashCommand,
      ],
      commandShortcutEvents: [
        // backspace
        backspaceCommand,
      ],
    );
  }

  Widget _buildMobileToolbar(BuildContext context, EditorState editorState) {
    return MobileToolbar(editorState: editorState);
  }
}
