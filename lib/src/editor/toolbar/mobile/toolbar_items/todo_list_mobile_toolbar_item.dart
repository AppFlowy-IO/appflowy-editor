import 'package:appflowy_editor/appflowy_editor.dart';

final todoListMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.checkbox),
  actionHandler: (editorState, selection) async {
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isTodoList = node.type == 'todo_list';

    editorState.formatNode(
      selection,
      (node) => node.copyWith(
        type: isTodoList ? 'paragraph' : 'todo_list',
        attributes: {
          'checked': false,
          'delta': (node.delta ?? Delta()).toJson(),
        },
      ),
    );
  },
);
