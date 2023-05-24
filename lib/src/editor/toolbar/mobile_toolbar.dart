import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
    required this.toolbarItems,
  });

  final EditorState editorState;
  final List<Widget> toolbarItems;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        final width = MediaQuery.of(context).size.width;
        return SizedBox(
          width: width,
          height: 50,
          child: Container(
            // TODO(yijing): expose background color in editor style
            color: const Color(0xFFF1F1F4),
            child: ListView.builder(
              itemBuilder: (context, index) => toolbarItems[index],
              itemCount: toolbarItems.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
        );
      },
    );
  }
}
