import 'package:appflowy_editor/appflowy_editor.dart';

final codeMobileToolbarItem = MobileToolbarItem.action(
  itemIcon: const AFMobileIcon(afMobileIcons: AFMobileIcons.code),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute(FlowyRichTextKeys.code),
);
