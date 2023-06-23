import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SimpleEditor extends StatelessWidget {
  const SimpleEditor({
    super.key,
    required this.jsonString,
    required this.onEditorStateChange,
    this.editorStyle,
  });

  final Future<String> jsonString;
  final EditorStyle? editorStyle;
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
            ..level = LogLevel.off;
          onEditorStateChange(editorState);
          final scrollController = ScrollController();
          if (PlatformExtension.isDesktopOrWeb) {
            return FloatingToolbar(
              items: [
                paragraphItem,
                ...headingItems,
                ...markdownFormatItems,
                quoteItem,
                bulletedListItem,
                numberedListItem,
                linkItem,
                textColorItem,
                highlightColorItem
              ],
              editorState: editorState,
              scrollController: scrollController,
              child: _buildDesktopEditor(
                context,
                editorState,
                scrollController,
              ),
            );
          } else if (PlatformExtension.isMobile) {
            return Column(
              children: [
                Expanded(
                  child: _buildMobileEditor(
                    context,
                    editorState,
                    scrollController,
                  ),
                ),
                MobileToolbar(
                  editorState: editorState,
                  toolbarItems: [
                    textDecorationMobileToolbarItem,
                    headingMobileToolbarItem,
                    todoListMobileToolbarItem,
                    listMobileToolbarItem,
                    linkMobileToolbarItem,
                    quoteMobileToolbarItem,
                    codeMobileToolbarItem,
                    // dividerMobileToolbarItem,
                  ],
                ),
              ],
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildMobileEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    return AppFlowyEditor.standard(
      editorStyle: const EditorStyle.mobile(),
      editorState: editorState,
      scrollController: scrollController,
    );
  }

  Widget _buildDesktopEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    final editorStyle = EditorStyle.desktop(
      // Example for customizing a new attribute key.
      textSpanDecorator: (textInsert, textSpan) {
        final attributes = textInsert.attributes;
        if (attributes == null) {
          return textSpan;
        }
        final mention = attributes['mention'] as Map?;
        if (mention != null) {
          return WidgetSpan(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  debugPrint('at');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_document),
                    Text(mention['id']),
                  ],
                ),
              ),
            ),
          );
        }
        return textSpan;
      },
    );
    return AppFlowyEditor.standard(
      editorStyle: editorStyle,
      editorState: editorState,
      scrollController: scrollController,
    );
  }
}
