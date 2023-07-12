import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<ToolbarItem> textDirectionItems = [
  _TextDirectionToolbarItem(
    id: 'text_direction_auto',
    name: blockComponentTextDirectionAuto,
    tooltip: AppFlowyEditorLocalizations.current.auto,
    icon: Icons.swap_horiz,
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_ltr',
    name: blockComponentTextDirectionLTR,
    tooltip: AppFlowyEditorLocalizations.current.ltr,
    icon: Icons.format_textdirection_l_to_r,
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_rtl',
    name: blockComponentTextDirectionRTL,
    tooltip: AppFlowyEditorLocalizations.current.rtl,
    icon: Icons.format_textdirection_r_to_l,
  ),
];

class _TextDirectionToolbarItem extends ToolbarItem {
  _TextDirectionToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required IconData icon,
  }) : super(
          id: 'editor.$id',
          group: 6,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentTextDirection] == name,
            );
            return SVGIconItemWidget(
              iconBuilder: (_) => Icon(
                icon,
                size: 16,
                color: isHighlight ? highlightColor : Colors.white,
              ),
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              tooltip: tooltip,
              onPressed: () => editorState.formatNode(
                selection,
                (node) => node.copyWith(
                  attributes: {
                    ...node.attributes,
                    blockComponentTextDirection: isHighlight ? null : name,
                  },
                ),
              ),
            );
          },
        );
}
