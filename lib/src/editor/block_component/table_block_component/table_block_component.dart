import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/selection_menu/selection_menu_icon.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'table_view.dart';

class TableBlockKeys {
  const TableBlockKeys._();

  static const String type = 'table';
}

class TableBlockComponentBuilder extends BlockComponentBuilder {
  TableBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TableBlockComponentWidget(
      key: node.key,
      tableNode: TableNode(node: node),
      node: node,
      configuration: configuration,
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
      node.attributes.containsKey('colsLen') &&
      node.attributes.containsKey('rowsLen');
}

class TableBlockComponentWidget extends BlockComponentStatefulWidget {
  const TableBlockComponentWidget({
    super.key,
    required this.tableNode,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  final TableNode tableNode;

  @override
  State<TableBlockComponentWidget> createState() =>
      _TableBlockComponentWidgetState();
}

class _TableBlockComponentWidgetState extends State<TableBlockComponentWidget>
    with SelectableMixin {
  late final editorState = Provider.of<EditorState>(context, listen: false);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 30, top: 8),
          child: TableView(
            tableNode: widget.tableNode,
            editorState: editorState,
          ),
        ),
      ),
    );
  }

  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  @override
  Position start() => Position(path: widget.tableNode.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.tableNode.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  List<Rect> getRectsInSelection(Selection selection) => [
        Offset.zero &
            Size(
              widget.tableNode.tableWidth + 10,
              widget.tableNode.colsHeight + 10,
            )
      ];

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.tableNode.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  bool get shouldCursorBlink => false;

  @override
  Offset localToGlobal(Offset offset) => _renderBox.localToGlobal(offset);
}

SelectionMenuItem tableMenuItem = SelectionMenuItem(
  name: 'Table',
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

    final tableNode = TableNode.fromList([
      ['', ''],
      ['', '']
    ]);

    final transaction = editorState.transaction
      ..insertNode(selection.end.path, tableNode.node);
    editorState.apply(transaction);
  },
);
