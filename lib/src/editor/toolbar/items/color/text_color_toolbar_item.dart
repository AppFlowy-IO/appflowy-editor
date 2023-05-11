import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/utils/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

final textColorItem = ToolbarItem(
  id: 'editor.textColor',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    String? textColorHex;

    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) {
          textColorHex = attributes['textColor'];
          return (textColorHex != null);
        },
      );
    });
    return IconItemWidget(
      iconName: 'toolbar/text_color',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.textColor,
      onPressed: () {
        showColorMenu(
          context,
          editorState,
          selection,
          currentColorHex: textColorHex,
          isTextColor: true,
        );
      },
    );
  },
);
