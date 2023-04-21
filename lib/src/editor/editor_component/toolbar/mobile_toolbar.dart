import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

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
          height: 30,
          child: Container(
            color: Colors.grey.withOpacity(0.3),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    editorState.selectionService.updateSelection(null);
                  },
                  icon: const Icon(Icons.keyboard_hide),
                ),
                const Text('FIXME: Mobile Toolbar'),
              ],
            ),
          ),
        );
      },
    );
  }
}
