import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// Not completed yet
class CollabEditor extends StatefulWidget {
  const CollabEditor({super.key});

  @override
  State<CollabEditor> createState() => _CollabEditorState();
}

class _CollabEditorState extends State<CollabEditor> {
  final EditorState editorStateA =
      EditorState(document: Document.blank(withInitialText: true));
  final EditorState editorStateB =
      EditorState(document: Document.blank(withInitialText: true));

  @override
  void initState() {
    super.initState();

    editorStateA.transactionStream.listen((event) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (event.$1 == TransactionTime.before) {
          editorStateB.apply(event.$2, isRemote: true);
        }
      });
    });

    editorStateB.transactionStream.listen((event) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (event.$1 == TransactionTime.before) {
          editorStateA.apply(event.$2, isRemote: true);
        }
      });
    });
  }

  @override
  void dispose() {
    editorStateA.dispose();
    editorStateB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: AppFlowyEditor(
              editorState: editorStateA,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: AppFlowyEditor(
              editorState: editorStateB,
            ),
          ),
        ],
      ),
    );
  }
}
