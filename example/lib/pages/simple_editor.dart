import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/src/infra/mobile/mobile.dart';

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
          final scrollController = ScrollController();
          if (PlatformExtension.isDesktopOrWeb) {
            return FloatingToolbar(
              items: [
                paragraphItem,
                ...headingItems,
                placeholderItem,
                ...markdownFormatItems,
                placeholderItem,
                quoteItem,
                bulletedListItem,
                numberedListItem,
                placeholderItem,
                linkItem,
                textColorItem,
                highlightColorItem
              ],
              editorState: editorState,
              scrollController: scrollController,
              child: _buildEditor(
                context,
                editorState,
                scrollController,
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: _buildMobileEditor(
                    context,
                    editorState,
                    scrollController,
                  ),
                ),
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

  Widget _buildMobileEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    return AppFlowyEditor.custom(
      editorStyle: const EditorStyle.mobile(),
      editorState: editorState,
      scrollController: scrollController,
      blockComponentBuilders: standardBlockComponentBuilderMap,
    );
  }

  Widget _buildEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    return AppFlowyEditor.standard(
      editorState: editorState,
      scrollController: scrollController,
    );
  }

  Widget _buildMobileToolbar(BuildContext context, EditorState editorState) {
    return MobileToolbar(
      editorState: editorState,
      // TODO(yijing): Implement toolbar features later
      toolbarItems: [
        IconButton(
          onPressed: () {
            editorState.selectionService.updateSelection(null);
          },
          icon: const Icon(Icons.keyboard_hide),
        ),
        ...AFMobileIcons.values
            .map(
              (e) => IconButton(
                onPressed: () {},
                icon: AFMobileIcon(
                  afMobileIcons: e,
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
