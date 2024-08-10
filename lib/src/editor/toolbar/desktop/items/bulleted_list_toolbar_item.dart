import 'package:appflowy_editor/appflowy_editor.dart';

const _kBulletedListItemId = 'editor.bulleted_list';

final ToolbarItem bulletedListItem = ToolbarItem(
  id: _kBulletedListItemId,
  group: 3,
  isActive: onlyShowInTextType,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'bulleted_list';
    final child = SVGIconItemWidget(
      iconName: 'toolbar/bulleted_list',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'bulleted_list',
        ),
      ),
    );

    if (tooltipBuilder != null) {
      return tooltipBuilder(
        context,
        _kBulletedListItemId,
        AppFlowyEditorL10n.current.bulletedList,
        child,
      );
    }

    return child;
  },
);
