import 'package:appflowy_editor/appflowy_editor.dart';

final todoListMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.checkbox),
  actionHandler: (editorState, selection) async {
    final node = editorState.getNodeAtPath(selection.start.path)!;
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
