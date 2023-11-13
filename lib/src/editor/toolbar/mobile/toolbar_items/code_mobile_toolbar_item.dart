import 'package:appflowy_editor/appflowy_editor.dart';

final codeMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (_, __) =>
      const AFMobileIcon(afMobileIcons: AFMobileIcons.code),
  actionHandler: (editorState, selection) =>
      editorState.toggleAttribute(AppFlowyRichTextKeys.code),
);
