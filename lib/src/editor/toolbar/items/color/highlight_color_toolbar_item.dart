import 'package:appflowy_editor/appflowy_editor.dart';

final highlightColorItem = ToolbarItem(
  id: 'editor.highlightColor',
  group: 4,
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    String? highlightColorHex;

    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) {
          highlightColorHex = attributes['highlightColor'];
          return (highlightColorHex != null);
        },
      );
    });
    return IconItemWidget(
      iconName: 'toolbar/highlight_color',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.highlightColor,
      onPressed: () {
        showColorMenu(
          context,
          editorState,
          selection,
          currentColorHex: highlightColorHex,
          isTextColor: false,
        );
      },
    );
  },
);
