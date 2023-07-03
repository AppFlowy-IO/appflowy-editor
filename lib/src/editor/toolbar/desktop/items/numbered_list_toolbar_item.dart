import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem numberedListItem = ToolbarItem(
  id: 'editor.numbered_list',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'numbered_list';
    return IconItemWidget(
      iconName: 'toolbar/numbered_list',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.numberedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'numbered_list',
          attributes: {
            'delta': (node.delta ?? Delta()).toJson(),
          },
        ),
      ),
    );
  },
);
