import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DividerBlockKeys {
  const DividerBlockKeys._();

  static const String type = 'divider';
}

// creating a new callout node
Node dividerNode() {
  return Node(
    type: DividerBlockKeys.type,
  );
}

typedef DividerBlockWrapper = Widget Function(
  BuildContext context,
  Node node,
  Widget child,
);

class DividerBlockComponentBuilder extends BlockComponentBuilder {
  DividerBlockComponentBuilder({
    super.configuration,
    this.lineColor = Colors.grey,
    this.height = 10,
    this.wrapper,
  });

  final Color lineColor;
  final double height;
  final DividerBlockWrapper? wrapper;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return DividerBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      lineColor: lineColor,
      height: height,
      wrapper: wrapper,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) => node.children.isEmpty;
}

class DividerBlockComponentWidget extends BlockComponentStatefulWidget {
  const DividerBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.lineColor = Colors.grey,
    this.height = 10,
    this.wrapper,
  });

  final Color lineColor;
  final double height;
  final DividerBlockWrapper? wrapper;

  @override
  State<DividerBlockComponentWidget> createState() =>
      _DividerBlockComponentWidgetState();
}

class _DividerBlockComponentWidgetState
    extends State<DividerBlockComponentWidget>
    with SelectableMixin, BlockComponentConfigurable {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  final dividerKey = GlobalKey();
  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: widget.height,
      alignment: Alignment.center,
      child: Divider(
        color: widget.lineColor,
        thickness: 1,
      ),
    );

    child = Padding(
      key: dividerKey,
      padding: padding,
      child: child,
    );

    final editorState = context.read<EditorState>();

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      cursorColor: editorState.editorStyle.cursorColor,
      selectionColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
        BlockSelectionType.cursor,
        BlockSelectionType.selection,
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

    if (widget.wrapper != null) {
      child = widget.wrapper!(context, node, child);
    }

    return child;
  }

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

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
    if (_renderBox == null) {
      return null;
    }
    return getRectsInSelection(
      Selection.collapsed(position),
      shiftWithBaseOffset: shiftWithBaseOffset,
    ).firstOrNull;
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    if (_renderBox == null) {
      return [];
    }
    final parentBox = context.findRenderObject();
    final dividerBox = dividerKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && dividerBox is RenderBox) {
      return [
        (shiftWithBaseOffset
                ? dividerBox.localToGlobal(Offset.zero, ancestor: parentBox)
                : Offset.zero) &
            dividerBox.size,
      ];
    }
    return [Offset.zero & _renderBox!.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) =>
      _renderBox!.localToGlobal(offset);

  @override
  TextDirection textDirection() {
    return TextDirection.ltr;
  }
}
