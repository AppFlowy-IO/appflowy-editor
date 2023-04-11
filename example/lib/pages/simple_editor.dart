import 'dart:convert';

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

          return AppFlowyEditor(
            editorState: editorState,
            themeData: themeData,
            toolbarColor: Colors.white,
            toolbarElevation: 5,
            showDefaultToolbar: false,
            toolbarItems: [
              ToolbarItem(
                  id: 'appflowy.toolbar.highlight',
                  type: 4,
                  tooltipsMessage: "",
                  iconBuilder: (isHighlight) => FlowySvg(
                        name: 'toolbar/highlight',
                        color: isHighlight ? Colors.lightBlue : Colors.grey,
                      ),
                  validator: (editorState) {
                    final nodes = editorState
                        .service.selectionService.currentSelectedNodes
                        .whereType<TextNode>()
                        .where(
                          (textNode) =>
                              BuiltInAttributeKey.globalStyleKeys
                                  .contains(textNode.subtype) ||
                              textNode.subtype == null,
                        );
                    return nodes.isNotEmpty;
                  },
                  handler: (editorState, context) =>
                      formatHeading(editorState, BuiltInAttributeKey.h1),
                  highlightCallback: (editorState) => _allSatisfy(
                        editorState,
                        BuiltInAttributeKey.backgroundColor,
                        (value) {
                          return value != null &&
                              value != '0x00000000'; // transparent color;
                        },
                      ))
            ],
            autoFocus: editorState.document.isEmpty,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  bool _allSatisfy(
    EditorState editorState,
    String styleKey,
    bool Function(dynamic value) test,
  ) {
    final selection =
        editorState.service.selectionService.currentSelection.value;
    return selection != null &&
        editorState.selectedTextNodes.allSatisfyInSelection(
          selection,
          styleKey,
          test,
        );
  }
}
