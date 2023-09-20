import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'table_view.dart';

class TableBlockKeys {
  const TableBlockKeys._();

  static const String type = 'table';

  static const String colDefaultWidth = 'colDefaultWidth';

  static const String rowDefaultHeight = 'rowDefaultHeight';

  static const String colMinimumWidth = 'colMinimumWidth';

  static const String borderWidth = 'borderWidth';

  static const String colsLen = 'colsLen';

  static const String rowsLen = 'rowsLen';

  static const String colsHeight = 'colsHeight';
}

class TableDefaults {
  const TableDefaults._();

  static const double colWidth = 80.0;

  static const double rowHeight = 40.0;

  static const double colMinimumWidth = 40.0;

  static const double borderWidth = 2.0;

  static const Widget addIcon = Icon(Icons.add, size: 20);

  static const Widget handlerIcon = Icon(Icons.drag_indicator);

  static const Color borderColor = Colors.grey;

  static const Color borderHoverColor = Colors.blue;
}

enum TableDirection { row, col }

typedef TableBlockComponentMenuBuilder = Widget Function(
  Node,
  EditorState,
  int,
  TableDirection,
  VoidCallback?,
  VoidCallback?,
);

class TableBlockComponentBuilder extends BlockComponentBuilder {
  TableBlockComponentBuilder({
    super.configuration,
    this.addIcon = TableDefaults.addIcon,
    this.borderColor = TableDefaults.borderColor,
    this.borderHoverColor = TableDefaults.borderHoverColor,
    this.menuBuilder,
  });

  final Widget addIcon;
  final TableBlockComponentMenuBuilder? menuBuilder;

  final Color borderColor;
  final Color borderHoverColor;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TableBlockComponentWidget(
      key: node.key,
      tableNode: TableNode(node: node),
      node: node,
      configuration: configuration,
      addIcon: addIcon,
      menuBuilder: menuBuilder,
      borderColor: borderColor,
      borderHoverColor: borderHoverColor,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) =>
      node.attributes.isNotEmpty &&
      node.attributes.containsKey(TableBlockKeys.colsLen) &&
      node.attributes.containsKey(TableBlockKeys.rowsLen);
}

class TableBlockComponentWidget extends BlockComponentStatefulWidget {
  const TableBlockComponentWidget({
    super.key,
    required this.tableNode,
    required super.node,
    required this.addIcon,
    required this.borderColor,
    required this.borderHoverColor,
    this.menuBuilder,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  final TableNode tableNode;

  final Widget addIcon;
  final TableBlockComponentMenuBuilder? menuBuilder;

  final Color borderColor;
  final Color borderHoverColor;

  @override
  State<TableBlockComponentWidget> createState() =>
      _TableBlockComponentWidgetState();
}

class _TableBlockComponentWidgetState extends State<TableBlockComponentWidget>
    with SelectableMixin, BlockComponentConfigurable {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  late final editorState = Provider.of<EditorState>(context, listen: false);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget child = Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, left: 10, bottom: 4),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: TableView(
          tableNode: widget.tableNode,
          editorState: editorState,
          addIcon: widget.addIcon,
          menuBuilder: widget.menuBuilder,
          borderColor: widget.borderColor,
          borderHoverColor: widget.borderHoverColor,
        ),
      ),
    );

    child = Padding(
      key: tableKey,
      padding: padding,
      child: child,
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  final tableKey = GlobalKey();
  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    final parentBox = context.findRenderObject();
    final tableBox = tableKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && tableBox is RenderBox) {
      return [
        (shiftWithBaseOffset
                ? tableBox.localToGlobal(Offset.zero, ancestor: parentBox)
                : Offset.zero) &
            tableBox.size,
      ];
    }
    return [Offset.zero & _renderBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) =>
      _renderBox.localToGlobal(offset);

  @override
  Rect getBlockRect({
    bool shiftWithBaseOffset = false,
  }) {
    return getRectsInSelection(Selection.invalid()).first;
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    final size = _renderBox.size;
    return Rect.fromLTWH(-size.width / 2.0, 0, size.width, size.height);
  }
}

SelectionMenuItem tableMenuItem = SelectionMenuItem(
  name: AppFlowyEditorLocalizations.current.table,
  icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
    icon: Icons.table_view,
    isSelected: isSelected,
    style: style,
  ),
  keywords: ['table'],
  handler: (editorState, _, __) {
    final selection = editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }

    final currentNode = editorState.getNodeAtPath(selection.end.path);
    if (currentNode == null) {
      return;
    }

    final tableNode = TableNode.fromList([
      ['', ''],
      ['', ''],
    ]);

    final transaction = editorState.transaction;
    final delta = currentNode.delta;
    if (delta != null && delta.isEmpty) {
      transaction
        ..insertNode(selection.end.path, tableNode.node)
        ..deleteNode(currentNode);
      transaction.afterSelection = Selection.collapsed(
        Position(
          path: selection.end.path + [0, 0],
          offset: 0,
        ),
      );
    } else {
      transaction.insertNode(selection.end.path.next, tableNode.node);
      transaction.afterSelection = Selection.collapsed(
        Position(
          path: selection.end.path.next + [0, 0],
          offset: 0,
        ),
      );
    }

    editorState.apply(transaction);
  },
);
