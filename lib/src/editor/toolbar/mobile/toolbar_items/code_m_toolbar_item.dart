import 'package:appflowy_editor/appflowy_editor.dart';

final codeMToolbarItem = MToolbarItem.action(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.code),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute('code'),
);
