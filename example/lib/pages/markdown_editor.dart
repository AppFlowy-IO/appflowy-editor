import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:example/pages/markdown/markdown_code_block_parser.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({super.key});

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  EditorState editorState = EditorState.blank();
  final controller = TextEditingController();
  final editorStyle = EditorStyle.desktop(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    cursorColor: Colors.transparent,
    cursorWidth: 0,
    selectionColor: Colors.grey.withValues(alpha: 0.3),
    textStyleConfiguration: TextStyleConfiguration(
      lineHeight: 1.2,
      applyHeightToFirstAscent: true,
      applyHeightToLastDescent: true,
      text: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      code: GoogleFonts.architectsDaughter(),
      bold: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
      ),
    ),
  );

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
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: editorStyle,
              editable: false,
              blockComponentBuilders: {
                ...standardBlockComponentBuilderMap,
                CodeBlockKeys.type: CodeBlockComponentBuilder(),
              },
            ),
          ),
          const VerticalDivider(),
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
    final document = markdownToDocument(
      controller.text,
      markdownParsers: [
        const MarkdownCodeBlockParserV2(),
      ],
    );
    setState(() {
      editorState = EditorState(document: document);
    });
  }
}
