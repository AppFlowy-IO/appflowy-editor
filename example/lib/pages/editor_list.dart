import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class EditorList extends StatefulWidget {
  const EditorList({
    super.key,
  });

  @override
  State<EditorList> createState() => _EditorListState();
}

class _EditorListState extends State<EditorList> {
  final List<Document> documents = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 100; i++) {
      final document = Document.blank()
        ..insert([
          0,
        ], [
          headingNode(level: 3, delta: Delta()..insert('Heading $i')),
          paragraphNode(
            delta: Delta()
              ..insert('Paragraph $i: ')
              ..insert(
                'formatted text',
                attributes: {'bold': true, 'italic': true, 'underline': true},
              ),
          ),
        ]);
      documents.add(document);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Editor List'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: documents
              .map(
                (e) => [
                  AppFlowyEditor(
                    editorState: EditorState(document: e),
                    shrinkWrap: true,
                    editable: false,
                  ),
                  const Divider(),
                ],
              )
              .expand((element) => element)
              .toList(),
        ),
      ),
    );
  }
}
