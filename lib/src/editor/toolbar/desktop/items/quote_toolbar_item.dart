import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem quoteItem = ToolbarItem(
  id: 'editor.quote',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'quote';
    return SVGIconItemWidget(
      iconName: 'toolbar/quote',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      tooltip: AppFlowyEditorL10n.current.quote,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'quote',
        ),
      ),
    );
  },
);
