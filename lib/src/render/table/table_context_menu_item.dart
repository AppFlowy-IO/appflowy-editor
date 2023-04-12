import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/color_menu/color_picker.dart';
import 'package:appflowy_editor/src/render/table/table_action.dart';
import 'package:flutter/material.dart';

// TODO(zoli): better to have sub context menu
final tableContextMenuItems = [
  [
    ContextMenuItem(
      name: 'Add Column',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var tableNode = _getTableCellNode(editorState).parent!;
        final transaction = editorState.transaction;
        addCol(tableNode, transaction);
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Add Row',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var tableNode = _getTableCellNode(editorState).parent!;
        final transaction = editorState.transaction;
        addRow(tableNode, transaction);
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Remove Column',
      isApplicable: (EditorState editorState) {
        if (!_isSelectionInTable(editorState)) {
          return false;
        }
        var tableNode = _getTableCellNode(editorState).parent!;
        return tableNode.attributes['colsLen'] > 1;
      },
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        final transaction = editorState.transaction;
        removeCol(
          node.parent!,
          node.attributes['position']['col'],
          transaction,
        );
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Remove Row',
      isApplicable: (EditorState editorState) {
        if (!_isSelectionInTable(editorState)) {
          return false;
        }
        var tableNode = _getTableCellNode(editorState).parent!;
        return tableNode.attributes['rowsLen'] > 1;
      },
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        final transaction = editorState.transaction;
        removeRow(
          node.parent!,
          node.attributes['position']['row'],
          transaction,
        );
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Duplicate Column',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        final transaction = editorState.transaction;
        duplicateCol(
          node.parent!,
          node.attributes['position']['col'],
          transaction,
        );
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Duplicate Row',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        final transaction = editorState.transaction;
        duplicateRow(
          node.parent!,
          node.attributes['position']['row'],
          transaction,
        );
        editorState.apply(transaction);
      },
    ),
    ContextMenuItem(
      name: 'Column Background Color',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        _showColorMenu(
          node,
          editorState,
          node.attributes['position']['col'],
          setColBgColor,
        );
      },
    ),
    ContextMenuItem(
      name: 'Row Background Color',
      isApplicable: _isSelectionInTable,
      onPressed: (editorState) {
        var node = _getTableCellNode(editorState);
        _showColorMenu(
          node,
          editorState,
          node.attributes['position']['row'],
          setRowBgColor,
        );
      },
    ),
  ],
];

bool _isSelectionInTable(EditorState editorState) {
  var selection = editorState.service.selectionService.currentSelection.value;
  if (selection == null || !selection.isSingle) {
    return false;
  }

  var node = editorState.service.selectionService.currentSelectedNodes.first;

  return node.id == kTableCellType || node.parent?.type == kTableCellType;
}

Node _getTableCellNode(EditorState editorState) {
  var node = editorState.service.selectionService.currentSelectedNodes.first;
  return node.id == kTableCellType ? node : node.parent!;
}

OverlayEntry? _colorMenuOverlay;
EditorState? _editorState;

void _showColorMenu(
  Node node,
  EditorState editorState,
  int rowcol,
  void Function(Node, int, Transaction, String?) action,
) {
  late Rect matchRect = node.rect;

  _dismissColorMenu();
  _editorState = editorState;

  final style = editorState.editorStyle;
  _colorMenuOverlay = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: matchRect.bottom - 15,
        left: matchRect.left + 15,
        child: Material(
          color: Colors.transparent,
          child: ColorPicker(
            pickerBackgroundColor:
                style.selectionMenuBackgroundColor ?? Colors.white,
            pickerItemHoverColor: style.selectionMenuItemSelectedColor ??
                Colors.blue.withOpacity(0.3),
            pickerItemTextColor:
                style.selectionMenuItemTextColor ?? Colors.black,
            colorOptionLists: [
              ColorOptionList(
                header: 'background color',
                selectedColorHex: node.attributes['backgroundColor'],
                colorOptions: generateBackgroundColorOptions(editorState),
                onSubmittedAction: (color) {
                  final transaction = editorState.transaction;
                  var c = color == node.attributes['backgroundColor']
                      ? null
                      : color;
                  action(node.parent!, rowcol, transaction, c);
                  editorState.apply(transaction);
                  _dismissColorMenu();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
  Overlay.of(node.key.currentContext!).insert(_colorMenuOverlay!);

  editorState.service.scrollService?.disable();
  editorState.service.keyboardService?.disable();
  editorState.service.selectionService.currentSelection
      .addListener(_dismissColorMenu);
}

void _dismissColorMenu() {
  // workaround: SelectionService has been released after hot reload.
  final isSelectionDisposed =
      _editorState?.service.selectionServiceKey.currentState == null;
  if (isSelectionDisposed) {
    return;
  }
  if (_editorState?.service.selectionService.currentSelection.value == null) {
    return;
  }
  _colorMenuOverlay?.remove();
  _colorMenuOverlay = null;

  _editorState?.service.scrollService?.enable();
  _editorState?.service.keyboardService?.enable();
  _editorState?.service.selectionService.currentSelection
      .removeListener(_dismissColorMenu);
  _editorState = null;
}
