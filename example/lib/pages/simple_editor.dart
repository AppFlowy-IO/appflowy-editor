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
            ..level = LogLevel.all;
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
                    textAndBackgroundColorMobileToolbarItem,
                    headingMobileToolbarItem,
                    todoListMobileToolbarItem,
                    listMobileToolbarItem,
                    linkMobileToolbarItem,
                    quoteMobileToolbarItem,
                    codeMobileToolbarItem,
                    // dividerMobileToolbarItem,
                  ],
                  textColorOptions: [
                    ColorOption(
                      colorHex: Colors.grey.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorGray,
                    ),
                    ColorOption(
                      colorHex: Colors.brown.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorBrown,
                    ),
                    ColorOption(
                      colorHex: Colors.yellow.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorYellow,
                    ),
                    ColorOption(
                      colorHex: Colors.green.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorGreen,
                    ),
                    ColorOption(
                      colorHex: Colors.blue.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorBlue,
                    ),
                    ColorOption(
                      colorHex: Colors.purple.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorPurple,
                    ),
                    ColorOption(
                      colorHex: Colors.pink.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorPink,
                    ),
                    ColorOption(
                      colorHex: Colors.red.toHex(),
                      name: AppFlowyEditorLocalizations.current.fontColorRed,
                    ),
                  ],
                  backgroundColorOptions: [
                    ColorOption(
                      colorHex: Colors.grey.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorGray,
                    ),
                    ColorOption(
                      colorHex: Colors.brown.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorBrown,
                    ),
                    ColorOption(
                      colorHex: Colors.yellow.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorYellow,
                    ),
                    ColorOption(
                      colorHex: Colors.green.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorGreen,
                    ),
                    ColorOption(
                      colorHex: Colors.blue.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorBlue,
                    ),
                    ColorOption(
                      colorHex: Colors.purple.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorPurple,
                    ),
                    ColorOption(
                      colorHex: Colors.pink.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorPink,
                    ),
                    ColorOption(
                      colorHex: Colors.red.withOpacity(0.3).toHex(),
                      name: AppFlowyEditorLocalizations
                          .current.backgroundColorRed,
                    ),
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
    return AppFlowyEditor.standard(
      editorStyle: const EditorStyle.desktop(),
      editorState: editorState,
      scrollController: scrollController,
    );
  }
}
