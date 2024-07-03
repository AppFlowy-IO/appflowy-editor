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
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: const EditorStyle.desktop(
                padding: EdgeInsets.zero,
                textStyleConfiguration: TextStyleConfiguration(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                  text: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              editable: false,
            ),
          ),
          const Divider(),
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
