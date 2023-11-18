import 'package:appflowy_editor/appflowy_editor.dart';

final todoListMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (_, __, ___) => const AFMobileIcon(
    afMobileIcons: AFMobileIcons.checkbox,
  ),
  actionHandler: (context, editorState) async {
    final selection = editorState.selection;
    if (selection == null) {
      return;
    }
    final node = editorState.getNodeAtPath(selection.start.path);
    if (node == null) {
      return;
    }
    final isTodoList = node.type == TodoListBlockKeys.type;

    editorState.formatNode(
      selection,
      (node) => node.copyWith(
        type: isTodoList ? ParagraphBlockKeys.type : TodoListBlockKeys.type,
        attributes: {
          TodoListBlockKeys.checked: false,
          ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
        },
      ),
    );
  },
);
