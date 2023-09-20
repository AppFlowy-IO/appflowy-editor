import 'package:appflowy_editor/appflowy_editor.dart';

final List<ToolbarItem> textDirectionItems = [
  _TextDirectionToolbarItem(
    id: 'text_direction_auto',
    name: blockComponentTextDirectionAuto,
    tooltip: AppFlowyEditorLocalizations.current.auto,
    iconName: 'text_direction_auto',
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_ltr',
    name: blockComponentTextDirectionLTR,
    tooltip: AppFlowyEditorLocalizations.current.ltr,
    iconName: 'text_direction_left',
  ),
  _TextDirectionToolbarItem(
    id: 'text_direction_rtl',
    name: blockComponentTextDirectionRTL,
    tooltip: AppFlowyEditorLocalizations.current.rtl,
    iconName: 'text_direction_right',
  ),
];

class _TextDirectionToolbarItem extends ToolbarItem {
  _TextDirectionToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required String iconName,
  }) : super(
          id: 'editor.$id',
          group: 7,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentTextDirection] == name,
            );
            return SVGIconItemWidget(
              iconName: 'toolbar/$iconName',
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              tooltip: tooltip,
              onPressed: () => editorState.updateNode(
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
