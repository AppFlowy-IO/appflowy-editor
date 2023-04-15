import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/color_menu/color_picker.dart';
import 'package:appflowy_editor/src/render/table/table_action.dart';
import 'package:appflowy_editor/src/render/table/table_const.dart';

// TODO(zoli): better to have sub context menu
final tableContextMenuItems = [
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
        node.attributes['colPosition'],
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
        node.attributes['rowPosition'],
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
        node.attributes['colPosition'],
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
        node.attributes['rowPosition'],
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
        node.attributes['colPosition'],
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
        node.attributes['rowPosition'],
        setRowBgColor,
      );
    },
  ),
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
                colorOptions: _generateBackgroundColorOptions(editorState),
                onSubmittedAction: (color) {
                  final transaction = editorState.transaction;
                  action(node.parent!, rowcol, transaction, color);
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
  if (isSelectionDisposed ||
      _editorState?.service.selectionService.currentSelection.value == null) {
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

List<ColorOption> _generateBackgroundColorOptions(EditorState editorState) {
  final defaultBackgroundColor =
      editorState.editorStyle.backgroundColor ?? Colors.white;
  return [
    ColorOption(
      colorHex: defaultBackgroundColor.toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorDefault,
    ),
    ColorOption(
      colorHex: Colors.grey.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorGray,
    ),
    ColorOption(
      colorHex: Colors.brown.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorBrown,
    ),
    ColorOption(
      colorHex: Colors.yellow.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorYellow,
    ),
    ColorOption(
      colorHex: Colors.green.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorGreen,
    ),
    ColorOption(
      colorHex: Colors.blue.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorBlue,
    ),
    ColorOption(
      colorHex: Colors.purple.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorPurple,
    ),
    ColorOption(
      colorHex: Colors.pink.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorPink,
    ),
    ColorOption(
      colorHex: Colors.red.withOpacity(0.3).toHex(),
      name: AppFlowyEditorLocalizations.current.backgroundColorRed,
    ),
  ];
}
