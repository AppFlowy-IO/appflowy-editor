import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum HorizontalPosition { left, center, right }

enum VerticalPosition { top, middle, bottom }

class DragToReorderEditor extends StatefulWidget {
  const DragToReorderEditor({
    super.key,
  });

  @override
  State<DragToReorderEditor> createState() => _DragToReorderEditorState();
}

class _DragToReorderEditorState extends State<DragToReorderEditor> {
  late final EditorState editorState;
  late final EditorStyle editorStyle;
  late final Map<String, BlockComponentBuilder> blockComponentBuilders;

  @override
  void initState() {
    super.initState();

    forceShowBlockAction = true;
    editorState = _createEditorState();
    editorStyle = _createEditorStyle();
    blockComponentBuilders = _createBlockComponentBuilders();
  }

  @override
  void dispose() {
    forceShowBlockAction = false;
    editorState.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag to reorder'),
      ),
      body: AppFlowyEditor(
        editorState: editorState,
        editorStyle: editorStyle,
        blockComponentBuilders: blockComponentBuilders,
        dropTargetStyle: const AppFlowyDropTargetStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Map<String, BlockComponentBuilder> _createBlockComponentBuilders() {
    final builders = {...standardBlockComponentBuilderMap};
    for (final entry in builders.entries) {
      if (entry.key == PageBlockKeys.type) {
        continue;
      }

      final builder = entry.value;

      // only customize the todo list block
      if (entry.key == TodoListBlockKeys.type) {
        builder.showActions = (_) => true;
        builder.actionBuilder = (context, actionState) {
          return DragToReorderAction(
            blockComponentContext: context,
            builder: builder,
          );
        };
      }
    }
    return builders;
  }

  EditorState _createEditorState() {
    final document = Document.blank()
      ..insert([
        0,
      ], [
        todoListNode(checked: false, text: 'Todo 1'),
        todoListNode(checked: false, text: 'Todo 2'),
        todoListNode(checked: false, text: 'Todo 3'),
      ]);
    return EditorState(
      document: document,
    );
  }

  EditorStyle _createEditorStyle() {
    return EditorStyle.desktop(
      cursorWidth: 2.0,
      cursorColor: Colors.black,
      selectionColor: Colors.grey.shade300,
      textStyleConfiguration: TextStyleConfiguration(
        text: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black,
        ),
        code: GoogleFonts.architectsDaughter(),
        bold: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 200.0),
    );
  }
}

class DragToReorderAction extends StatefulWidget {
  const DragToReorderAction({
    super.key,
    required this.blockComponentContext,
    required this.builder,
  });

  final BlockComponentContext blockComponentContext;
  final BlockComponentBuilder builder;

  @override
  State<DragToReorderAction> createState() => _DragToReorderActionState();
}

const _interceptorKey = 'drag_to_reorder_interceptor';

class _DragToReorderActionState extends State<DragToReorderAction> {
  late final Node node;
  late final BlockComponentContext blockComponentContext;
  late final EditorState editorState = context.read<EditorState>();

  Offset? globalPosition;

  late final gestureInterceptor = SelectionGestureInterceptor(
    key: _interceptorKey,
    canTap: (details) => !_isTapInBounds(details.globalPosition),
  );

  // the selection will be cleared when tap the option button
  // so we need to restore the selection after tap the option button
  Selection? beforeSelection;
  RenderBox? get renderBox => context.findRenderObject() as RenderBox?;

  @override
  void initState() {
    super.initState();

    editorState.service.selectionService.registerGestureInterceptor(
      gestureInterceptor,
    );

    // copy the node to avoid the node in document being updated
    node = widget.blockComponentContext.node.copyWith();
    blockComponentContext = BlockComponentContext(
      widget.blockComponentContext.buildContext,
      node,
    );
  }

  @override
  void dispose() {
    editorState.service.selectionService.unregisterGestureInterceptor(
      _interceptorKey,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 4.0),
      child: Draggable<Node>(
        data: node,
        feedback: _buildFeedback(),
        onDragStarted: () {
          debugPrint('onDragStarted');
          editorState.selectionService.removeDropTarget();
        },
        onDragUpdate: (details) {
          editorState.selectionService.renderDropTargetForOffset(
            details.globalPosition,
            builder: (context, data) => _buildDropArea(
              context,
              data,
              widget.blockComponentContext.node,
            ),
          );

          globalPosition = details.globalPosition;

          editorState.scrollService?.startAutoScroll(details.globalPosition);
        },
        onDragEnd: (details) {
          editorState.selectionService.removeDropTarget();

          if (globalPosition == null) {
            return;
          }

          final data = editorState.selectionService.getDropTargetRenderData(
            globalPosition!,
          );

          final acceptedPath = data?.dropPath;

          debugPrint('onDragEnd, acceptedPath($acceptedPath)');

          _moveNodeToNewPosition(
            widget.blockComponentContext.node,
            data?.cursorNode?.path,
            globalPosition!,
          );
        },
        child: GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.translucent,
          child: const MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() {
    final path = widget.blockComponentContext.node.path;

    debugPrint('onTap, path($path), beforeSelection($beforeSelection)');

    if (beforeSelection != null && path.inSelection(beforeSelection)) {
      debugPrint('onTap(1), set selection to block');
      editorState.updateSelectionWithReason(
        beforeSelection,
        customSelectionType: SelectionType.block,
      );
    } else {
      debugPrint('onTap(2), set selection to block');
      final selection = Selection.collapsed(
        Position(path: path),
      );
      editorState.updateSelectionWithReason(
        selection,
        customSelectionType: SelectionType.block,
      );
    }
  }

  bool _isTapInBounds(Offset offset) {
    if (renderBox == null) {
      return false;
    }

    final localPosition = renderBox!.globalToLocal(offset);
    final result = renderBox!.paintBounds.contains(localPosition);
    if (result) {
      beforeSelection = editorState.selection;
    } else {
      beforeSelection = null;
    }
    return result;
  }

  Future<void> _moveNodeToNewPosition(
    Node node,
    Path? acceptedPath,
    Offset dragOffset,
  ) async {
    if (acceptedPath == null) return;

    final editorState = context.read<EditorState>();
    final targetNode = editorState.getNodeAtPath(acceptedPath);
    if (targetNode == null) return;

    final position = _getPosition(context, targetNode, dragOffset);
    if (position == null) return;

    final (verticalPosition, horizontalPosition, _) = position;
    Path newPath = targetNode.path;

    final realNode = widget.blockComponentContext.node;
    debugPrint('Moving node($realNode, ${realNode.path}) to path($newPath)');

    // if the horizontal position is right, we need to create a column block
    if (horizontalPosition == HorizontalPosition.right) {
      final node = columnsNode(
        children: [
          columnNode(
            children: [targetNode.deepCopy()],
          ),
          columnNode(
            children: [realNode.deepCopy()],
          ),
        ],
      );

      final transaction = editorState.transaction;
      transaction.insertNode(newPath, node);
      transaction.deleteNode(targetNode);
      transaction.deleteNode(realNode);
      await editorState.apply(transaction);
    } else {
      // Determine the new path based on drop position
      // For VerticalPosition.top, we keep the target node's path
      if (verticalPosition == VerticalPosition.bottom) {
        newPath = horizontalPosition == HorizontalPosition.left
            ? newPath.next // Insert after target node
            : newPath.child(0); // Insert as first child of target node
      }

      // Check if the drop should be ignored
      if (_shouldIgnoreDrop(node, newPath)) {
        debugPrint(
          'Drop ignored: node($node, ${node.path}), path($acceptedPath)',
        );
        return;
      }

      // Perform the node move operation
      final transaction = editorState.transaction;
      transaction.moveNode(newPath, realNode);
      await editorState.apply(transaction);
    }
  }

  Widget _buildFeedback() {
    Widget child;
    if (node.type == TableBlockKeys.type) {
      // unable to render table block without provider/context
      // render a placeholder instead
      child = Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Table'),
      );
    } else {
      child = IntrinsicWidth(
        child: IntrinsicHeight(
          child: Provider.value(
            value: editorState,
            child: widget.builder.build(blockComponentContext),
          ),
        ),
      );
    }

    return Opacity(
      opacity: 0.7,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

Widget _buildDropArea(
  BuildContext context,
  DragAreaBuilderData data,
  Node dragNode,
) {
  final targetNode = data.targetNode;

  final shouldIgnoreDrop = _shouldIgnoreDrop(dragNode, targetNode.path);
  if (shouldIgnoreDrop) {
    return const SizedBox.shrink();
  }

  final selectable = targetNode.selectable;
  final renderBox = selectable?.context.findRenderObject() as RenderBox?;
  if (selectable == null || renderBox == null) {
    return const SizedBox.shrink();
  }

  final position = _getPosition(
    context,
    targetNode,
    data.dragOffset,
  );

  if (position == null) {
    return const SizedBox.shrink();
  }

  final (verticalPosition, horizontalPosition, globalBlockRect) = position;

  // 44 is the width of the drag indicator
  const indicatorWidth = 44.0;
  final width = globalBlockRect.width - indicatorWidth;

  Widget child = Container(
    height: 2,
    width: width,
    color: Colors.red,
  );

  if (horizontalPosition == HorizontalPosition.center) {
    const breakWidth = 22.0;
    const padding = 8.0;
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 2,
          width: breakWidth,
          color: Colors.red,
        ),
        const SizedBox(width: padding),
        Container(
          height: 2,
          width: width - breakWidth - padding,
          color: Colors.red,
        ),
      ],
    );
  } else if (horizontalPosition == HorizontalPosition.right) {
    return Positioned(
      top: globalBlockRect.top,
      height: globalBlockRect.height,
      left: globalBlockRect.right - 2,
      child: Container(
        width: 2,
        color: Colors.red,
      ),
    );
  }

  return Positioned(
    top: verticalPosition == VerticalPosition.top
        ? globalBlockRect.top
        : globalBlockRect.bottom,
    left: globalBlockRect.left + 22,
    child: child,
  );
}

(VerticalPosition, HorizontalPosition, Rect)? _getPosition(
  BuildContext context,
  Node dragTargetNode,
  Offset dragOffset,
) {
  final selectable = dragTargetNode.selectable;
  final renderBox = selectable?.context.findRenderObject() as RenderBox?;
  if (selectable == null || renderBox == null) {
    return null;
  }

  final globalBlockOffset = renderBox.localToGlobal(Offset.zero);
  final globalBlockRect = globalBlockOffset & renderBox.size;

  // Check if the dragOffset is within the globalBlockRect
  final isInside = globalBlockRect.contains(dragOffset);

  if (!isInside) {
    debugPrint(
      'the drag offset is not inside the block, dragOffset($dragOffset), globalBlockRect($globalBlockRect)',
    );
    return null;
  }

  debugPrint(
    'the drag offset is inside the block, dragOffset($dragOffset), globalBlockRect($globalBlockRect)',
  );

  // Determine the relative position
  HorizontalPosition horizontalPosition;
  VerticalPosition verticalPosition;

  // Horizontal position
  if (dragOffset.dx < globalBlockRect.left + 44) {
    horizontalPosition = HorizontalPosition.left;
  } else if (dragOffset.dx > globalBlockRect.right / 3.0 * 2.0) {
    horizontalPosition = HorizontalPosition.right;
  } else {
    horizontalPosition = HorizontalPosition.center;
  }

  // Vertical position
  if (dragOffset.dy < globalBlockRect.top + globalBlockRect.height / 2) {
    verticalPosition = VerticalPosition.top;
  } else {
    verticalPosition = VerticalPosition.bottom;
  }

  return (verticalPosition, horizontalPosition, globalBlockRect);
}

bool _shouldIgnoreDrop(Node dragNode, Path? targetPath) {
  if (targetPath == null) {
    return true;
  }

  if (dragNode.path.equals(targetPath)) {
    return true;
  }

  if (dragNode.path.isAncestorOf(targetPath)) {
    return true;
  }

  return false;
}
