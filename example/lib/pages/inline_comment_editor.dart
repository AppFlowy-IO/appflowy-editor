import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class InlineCommentEditor extends StatefulWidget {
  const InlineCommentEditor({super.key});

  @override
  State<InlineCommentEditor> createState() => _InlineCommentEditorState();
}

class _InlineCommentEditorState extends State<InlineCommentEditor> {
  late final EditorState editorState;
  late final EditorScrollController editorScrollController;
  late final InlineCommentController commentController;
  final List<InlineComment> _comments = [];
  int _commentCounter = 0;

  @override
  void initState() {
    super.initState();

    // Create a document with some example text
    final document = Document(
      root: pageNode(
        children: [
          headingNode(
            level: 1,
            delta: Delta()..insert('Inline Comment Demo'),
          ),
          paragraphNode(
            delta: Delta()
              ..insert(
                'Select any text in this editor and click the comment button '
                'in the floating toolbar to add a comment. '
                'The commented text will be highlighted with a yellow background.',
              ),
          ),
          paragraphNode(
            delta: Delta()
              ..insert(
                'You can also click on highlighted text to see which comment '
                'is associated with it. The sidebar on the right shows all '
                'comments with their positions aligned to the text.',
              ),
          ),
          paragraphNode(
            delta: Delta()
              ..insert(
                'Try adding multiple comments to different parts of the text '
                'and observe how the sidebar updates automatically.',
              ),
          ),
        ],
      ),
    );

    editorState = EditorState(document: document);

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    commentController = InlineCommentController(
      onCommentAdded: _onCommentAdded,
      onCommentDeleted: _onCommentDeleted,
      onCommentTapped: _onCommentTapped,
    );
  }

  @override
  void dispose() {
    editorScrollController.dispose();
    editorState.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<String?> _onCommentAdded(
    String nodeId,
    int startOffset,
    int endOffset,
    String? initialText,
  ) async {
    // Show a dialog for the user to enter a comment
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your comment...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, textController.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (content == null || content.isEmpty) return null;

    final commentId = 'cmt-${++_commentCounter}';
    final comment = InlineComment(
      id: commentId,
      content: content,
      authorName: 'Demo User',
      createdAt: DateTime.now(),
    );

    setState(() => _comments.add(comment));
    commentController.updateComments(_comments);

    return commentId;
  }

  Future<void> _onCommentDeleted(String commentId) async {
    setState(() => _comments.removeWhere((c) => c.id == commentId));
    commentController.updateComments(_comments);
  }

  void _onCommentTapped(String commentId, BuildContext context) {
    final comment = commentController.findById(commentId);
    if (comment == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${comment.authorName}: ${comment.content}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inline Comment Demo')),
      body: InlineCommentWidget(
        editorState: editorState,
        controller: commentController,
        showSidebar: true,
        sidebarWidth: 260,
        child: FloatingToolbar(
          items: [
            paragraphItem,
            ...headingItems,
            ...markdownFormatItems,
            quoteItem,
            bulletedListItem,
            numberedListItem,
            linkItem,
            buildTextColorItem(),
            buildHighlightColorItem(),
            buildCommentToolbarItem(commentController),
          ],
          tooltipBuilder: (context, _, message, child) {
            return Tooltip(
              message: message,
              preferBelow: false,
              child: child,
            );
          },
          editorState: editorState,
          editorScrollController: editorScrollController,
          textDirection: TextDirection.ltr,
          child: AppFlowyEditor(
            editorState: editorState,
            editorScrollController: editorScrollController,
            editorStyle: EditorStyle.desktop(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              textSpanDecorator: buildCommentTextSpanDecorator(
                controller: commentController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
