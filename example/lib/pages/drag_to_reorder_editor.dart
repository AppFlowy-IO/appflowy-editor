import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

class _DragToReorderActionState extends State<DragToReorderAction> {
  late final Node node;
  late final BlockComponentContext blockComponentContext;
  late final EditorState editorState = context.read<EditorState>();

  Offset? globalPosition;

  @override
  void initState() {
    super.initState();

    // copy the node to avoid the node in document being updated
    node = widget.blockComponentContext.node.copyWith();
    blockComponentContext = BlockComponentContext(
      widget.blockComponentContext.buildContext,
      node,
    );
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

          _moveNodeToNewPosition(node, acceptedPath);
        },
        child: const MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Icon(
            Icons.drag_indicator_rounded,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _moveNodeToNewPosition(Node node, Path? acceptedPath) async {
    if (acceptedPath == null) {
      debugPrint('acceptedPath is null');
      return;
    }

    debugPrint('move node($node) to path($acceptedPath)');

    final editorState = context.read<EditorState>();
    final transaction = editorState.transaction;
    transaction.moveNode(acceptedPath, widget.blockComponentContext.node);
    await editorState.apply(transaction);
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
