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
        builder.configuration = builder.configuration.copyWith(
          enableDragToReorder: true,
        );
        builder.showActions = (_) => true;
        builder.actionBuilder = (context, actionState) {
          return _DragToReorderAction(
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

class _DragToReorderAction extends StatefulWidget {
  const _DragToReorderAction({
    required this.blockComponentContext,
    required this.builder,
  });

  final BlockComponentContext blockComponentContext;
  final BlockComponentBuilder builder;

  @override
  State<_DragToReorderAction> createState() => _DragToReorderActionState();
}

class _DragToReorderActionState extends State<_DragToReorderAction> {
  late final Node node;
  late final BlockComponentContext blockComponentContext;

  Node? acceptedNode;

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
        feedback: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Provider.value(
              value: context.read<EditorState>(),
              child: widget.builder.build(blockComponentContext),
            ),
          ),
        ),
        onDragStarted: () {
          debugPrint('onDragStarted');
          context.read<EditorState>().selectionService.removeDropTarget();
        },
        onDragUpdate: (details) {
          final data = context
              .read<EditorState>()
              .selectionService
              .getDropTargetRenderData(details.globalPosition);
          if (data != null && data.dropTarget != null) {
            context
                .read<EditorState>()
                .selectionService
                .renderDropTargetForOffset(details.globalPosition);
            acceptedNode = data.cursorNode;
          } else {
            context.read<EditorState>().selectionService.removeDropTarget();
          }
        },
        onDragEnd: (details) {
          debugPrint('onDragEnd, acceptedNode: $acceptedNode');
          context.read<EditorState>().selectionService.removeDropTarget();
          _moveNodeToNewPosition(node, acceptedNode);
        },
        child: const Icon(
          Icons.drag_indicator_rounded,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _moveNodeToNewPosition(Node node, Node? acceptedNode) async {
    if (acceptedNode == null) {
      debugPrint('acceptedNode is null');
      return;
    }

    if (acceptedNode.id == node.id || acceptedNode.next?.id == node.id) {
      debugPrint('ignore the same position move');
      return;
    }

    debugPrint('move node($node) to position of node($acceptedNode)');

    final editorState = context.read<EditorState>();
    final transaction = editorState.transaction;
    transaction.insertNode(acceptedNode.path.next, node.copyWith());
    transaction.deleteNode(widget.blockComponentContext.node);
    await editorState.apply(transaction);
  }
}
