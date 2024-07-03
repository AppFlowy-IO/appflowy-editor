import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({super.key});

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  EditorState editorState = EditorState.blank();
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Markdown Editor'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Type markdown here ...',
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: const EditorStyle.desktop(padding: EdgeInsets.zero),
            ),
          ),
        ],
      ),
    );
  }

  void _onTextChanged() {
    final document = markdownToDocument(controller.text);
    setState(() {
      editorState = EditorState(document: document);
    });
  }
}
