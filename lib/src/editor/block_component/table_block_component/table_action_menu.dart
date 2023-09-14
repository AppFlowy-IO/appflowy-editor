import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/overlay_util.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

void showActionMenu(
  BuildContext context,
  Node node,
  EditorState editorState,
  int position,
  TableDirection dir,
) {
  final Offset pos =
      (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
  final rect = Rect.fromLTWH(
    pos.dx,
    pos.dy,
    context.size?.width ?? 0,
    context.size?.height ?? 0,
  );
  OverlayEntry? overlay;

  var (top, bottom, left) = positionFromRect(rect, editorState);
  top = top != null ? top - 35 : top;

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
  }

  overlay = FullScreenOverlayEntry(
    top: top,
    bottom: bottom,
    left: left,
    builder: (context) {
      return basicOverlay(
        context,
        width: 200,
        height: 230,
        children: [
          _menuItem(
              context,
              dir == TableDirection.col
                  ? AppFlowyEditorLocalizations.current.colAddAfter
                  : AppFlowyEditorLocalizations.current.rowAddAfter,
              dir == TableDirection.col
                  ? Icons.last_page
                  : Icons.vertical_align_bottom, () {
            TableActions.add(node, position + 1, editorState, dir);
            dismissOverlay();
          }),
          _menuItem(
              context,
              dir == TableDirection.col
                  ? AppFlowyEditorLocalizations.current.colAddBefore
                  : AppFlowyEditorLocalizations.current.rowAddBefore,
              dir == TableDirection.col
                  ? Icons.first_page
                  : Icons.vertical_align_top, () {
            TableActions.add(node, position, editorState, dir);
            dismissOverlay();
          }),
          _menuItem(
              context,
              dir == TableDirection.col
                  ? AppFlowyEditorLocalizations.current.colRemove
                  : AppFlowyEditorLocalizations.current.rowRemove,
              Icons.delete, () {
            TableActions.delete(node, position, editorState, dir);
            dismissOverlay();
          }),
          _menuItem(
              context,
              dir == TableDirection.col
                  ? AppFlowyEditorLocalizations.current.colDuplicate
                  : AppFlowyEditorLocalizations.current.rowDuplicate,
              Icons.content_copy, () {
            TableActions.duplicate(node, position, editorState, dir);
            dismissOverlay();
          }),
          _menuItem(
            context,
            AppFlowyEditorLocalizations.current.backgroundColor,
            Icons.format_color_fill,
            () {
              final cell = dir == TableDirection.col
                  ? getCellNode(node, position, 0)
                  : getCellNode(node, 0, position);
              final key = dir == TableDirection.col
                  ? TableCellBlockKeys.colBackgroundColor
                  : TableCellBlockKeys.rowBackgroundColor;

              _showColorMenu(
                context,
                (color) {
                  TableActions.setBgColor(
                    node,
                    position,
                    editorState,
                    color,
                    dir,
                  );
                },
                top: top,
                bottom: bottom,
                left: left,
                selectedColorHex: cell?.attributes[key],
              );
              dismissOverlay();
            },
          ),
          _menuItem(
              context,
              dir == TableDirection.col
                  ? AppFlowyEditorLocalizations.current.colClear
                  : AppFlowyEditorLocalizations.current.rowClear,
              Icons.clear, () {
            TableActions.clear(node, position, editorState, dir);
            dismissOverlay();
          }),
        ],
      );
    },
  ).build();
  Overlay.of(context).insert(overlay!);
}

Widget _menuItem(
  BuildContext context,
  String text,
  IconData icon,
  Function() action,
) {
  return SizedBox(
    height: 36,
    child: TextButton.icon(
      onPressed: () {
        action();
      },
      icon: Icon(icon, color: Theme.of(context).iconTheme.color),
      style: buildOverlayButtonStyle(context),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Theme.of(context).textTheme.labelLarge?.color,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showColorMenu(
  BuildContext context,
  Function(String?) action, {
  double? top,
  double? bottom,
  double? left,
  String? selectedColorHex,
}) {
  OverlayEntry? overlay;

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
  }

  overlay = FullScreenOverlayEntry(
    top: top,
    bottom: bottom,
    left: left,
    builder: (context) {
      return ColorPicker(
        title: AppFlowyEditorLocalizations.current.highlightColor,
        selectedColorHex: selectedColorHex,
        colorOptions: generateHighlightColorOptions(),
        onSubmittedColorHex: (color) {
          action(color);
          dismissOverlay();
        },
        resetText: AppFlowyEditorLocalizations.current.clearHighlightColor,
        resetIconName: 'clear_highlight_color',
      );
    },
  ).build();
  Overlay.of(context).insert(overlay!);
}
