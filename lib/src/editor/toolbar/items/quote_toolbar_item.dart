import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

final ToolbarItem quoteItem = ToolbarItem(
  id: 'editor.quote',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'quote';
    return IconItemWidget(
      iconName: 'toolbar/quote',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.quote,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'quote',
          attributes: {
            'delta': (node.delta ?? Delta()).toJson(),
          },
        ),
      ),
    );
  },
);
