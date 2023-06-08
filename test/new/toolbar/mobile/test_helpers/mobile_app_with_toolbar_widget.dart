import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

/// Used in testing mobile app with toolbar
class MobileAppWithToolbarWidget extends StatelessWidget {
  MobileAppWithToolbarWidget({
    required this.editorState,
    this.toolbarItems,
    super.key,
  });
  final EditorState editorState;
  final List<MobileToolbarItem>? toolbarItems;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final _toolbarItems = toolbarItems ??
        [
          textDecorationMobileToolbarItem,
          headingMobileToolbarItem,
          todoListMobileToolbarItem,
          listMobileToolbarItem,
          linkMobileToolbarItem,
          quoteMobileToolbarItem,
          codeMobileToolbarItem,
        ];
    return MaterialApp(
      home: Column(
        children: [
          Expanded(
            child: AppFlowyEditor.standard(
              editorStyle: const EditorStyle.mobile(),
              editorState: editorState,
              scrollController: scrollController,
            ),
          ),
          MobileToolbar(
            editorState: editorState,
            toolbarItems: _toolbarItems,
          ),
        ],
      ),
    );
  }
}
