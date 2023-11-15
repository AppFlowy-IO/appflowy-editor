import 'package:appflowy_editor/appflowy_editor.dart';

final codeMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (_, __, ___) => const AFMobileIcon(
    afMobileIcons: AFMobileIcons.code,
  ),
  actionHandler: (_, editorState) => editorState.toggleAttribute(
    AppFlowyRichTextKeys.code,
  ),
);
