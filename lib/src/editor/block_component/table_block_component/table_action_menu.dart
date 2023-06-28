import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/overlay_util.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

enum TableDirection { row, col }

void showColActionMenu(
  BuildContext context,
  Node node,
  EditorState editorState,
  int position,
) {
  _showActionMenu(
    context,
    node,
    editorState,
    position,
    TableDirection.col,
  );
}

void showRowActionMenu(
  BuildContext context,
  Node node,
  EditorState editorState,
  int position,
) {
  _showActionMenu(
    context,
    node,
    editorState,
    position,
    TableDirection.row,
  );
}

void _showActionMenu(
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
          _menuItem(context, 'Add after', Icons.last_page, () {
            final transaction = editorState.transaction;
            _add(node, position + 1, transaction, dir);
            editorState.apply(transaction);
            dismissOverlay();
          }),
          _menuItem(context, 'Add before', Icons.first_page, () {
            final transaction = editorState.transaction;
            _add(node, position, transaction, dir);
            editorState.apply(transaction);
            dismissOverlay();
          }),
          _menuItem(context, 'Remove', Icons.delete, () {
            final transaction = editorState.transaction;
            _remove(node, position, transaction, dir);
            editorState.apply(transaction);
            dismissOverlay();
          }),
          _menuItem(context, 'Duplicate', Icons.content_copy, () {
            final transaction = editorState.transaction;
            _duplicate(node, position, transaction, dir);
            editorState.apply(transaction);
            dismissOverlay();
          }),
          _menuItem(
            context,
            'Background Color',
            Icons.format_color_fill,
            () {
              final cell = dir == TableDirection.col
                  ? getCellNode(node, position, 0)
                  : getCellNode(node, 0, position);

              _showColorMenu(
                context,
                (color) {
                  final transaction = editorState.transaction;
                  _setBgColor(node, position, transaction, color, dir);
                  editorState.apply(transaction);
                },
                top: top,
                bottom: bottom,
                left: left,
                selectedColorHex: cell?.attributes['backgroundColor'],
              );
              dismissOverlay();
            },
          ),
          _menuItem(context, 'Clear Content', Icons.clear, () {
            final transaction = editorState.transaction;
            _clear(node, position, transaction, dir);
            editorState.apply(transaction);
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

void _add(
  Node node,
  int position,
  Transaction transaction,
  TableDirection dir,
) {
  if (dir == TableDirection.col) {
    addCol(node, position, transaction);
  } else {
    addRow(node, position, transaction);
  }
}

void _remove(
  Node node,
  int position,
  Transaction transaction,
  TableDirection dir,
) {
  if (dir == TableDirection.col) {
    removeCol(node, position, transaction);
  } else {
    removeRow(node, position, transaction);
  }
}

void _duplicate(
  Node node,
  int position,
  Transaction transaction,
  TableDirection dir,
) {
  if (dir == TableDirection.col) {
    duplicateCol(node, position, transaction);
  } else {
    duplicateRow(node, position, transaction);
  }
}

void _clear(
  Node node,
  int position,
  Transaction transaction,
  TableDirection dir,
) {
  if (dir == TableDirection.col) {
    clearCol(node, position, transaction);
  } else {
    clearRow(node, position, transaction);
  }
}

void _setBgColor(
  Node node,
  int position,
  Transaction transaction,
  String? color,
  TableDirection dir,
) {
  if (dir == TableDirection.col) {
    setColBgColor(node, position, transaction, color);
  } else {
    setRowBgColor(node, position, transaction, color);
  }
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
