import 'package:appflowy_editor/appflowy_editor.dart';

final quoteMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (_, __, ___) => const AFMobileIcon(
    afMobileIcons: AFMobileIcons.quote,
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
    final isQuote = node.type == QuoteBlockKeys.type;
    editorState.formatNode(
      selection,
      (node) => node.copyWith(
        type: isQuote ? ParagraphBlockKeys.type : QuoteBlockKeys.type,
        attributes: {
          ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
        },
      ),
    );
  },
);
