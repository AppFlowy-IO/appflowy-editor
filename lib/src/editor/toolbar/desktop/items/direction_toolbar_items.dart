import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<ToolbarItem> textDirectionItems = [
  _FormatToolbarItem(
    id: 'auto',
    name: 'auto',
    tooltip: AppFlowyEditorLocalizations.current.auto,
    icon: Icons.swap_horiz,
  ),
  _FormatToolbarItem(
    id: 'ltr',
    name: 'ltr',
    tooltip: AppFlowyEditorLocalizations.current.ltr,
    icon: Icons.format_textdirection_l_to_r,
  ),
  _FormatToolbarItem(
    id: 'rtl',
    name: 'rtl',
    tooltip: AppFlowyEditorLocalizations.current.rtl,
    icon: Icons.format_textdirection_r_to_l,
  ),
];

class _FormatToolbarItem extends ToolbarItem {
  _FormatToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required IconData icon,
  }) : super(
          id: 'editor.$id',
          group: 6,
          isActive: (editorState) {
            final selection = editorState.selection;
            if (selection == null) {
              return false;
            }
            final nodes = editorState.getNodesInSelection(selection);
            return nodes.every((element) => element.delta != null);
          },
          builder: (context, editorState) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every((n) => n.attributes['dir'] == name);
            return MaterialIconItemWidget(
              icon: icon,
              isHighlight: isHighlight,
              tooltip: tooltip,
              onPressed: () => editorState.formatNode(
                selection,
                (node) => node.copyWith(
                  attributes: {
                    ...node.attributes,
                    FlowyRichTextKeys.dir: isHighlight ? '' : name,
                  },
                ),
              ),
            );
          },
        );
}
