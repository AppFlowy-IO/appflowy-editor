import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../new/util/util.dart';

void main() async {
  testWidgets('auto complete', (tester) async {
    const input = 'Hello';
    final document = Document.blank()
      ..addParagraph(
        initialText: input,
      );
    final editorState = EditorState(document: document);

    final widget = AutoCompleteEditor(
      editorState: editorState,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    editorState.selection = Selection.collapsed(
      Position(path: [0], offset: input.length),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('world', findRichText: true),
      findsOneWidget,
    );

    editorState.selection = Selection(
      start: Position(path: [0], offset: 0),
      end: Position(path: [0], offset: input.length),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('world', findRichText: true),
      findsNothing,
    );
  });
}

class AutoCompleteEditor extends StatelessWidget {
  const AutoCompleteEditor({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: AppFlowyEditor(
              editorState: editorState,
              enableAutoComplete: true,
              autoCompleteTextProvider: (context, node, textSpan) {
                final editorState = context.read<EditorState>();
                final selection = editorState.selection;
                final delta = node.delta;
                if (selection == null ||
                    delta == null ||
                    !selection.isCollapsed ||
                    selection.endIndex != delta.length ||
                    !node.path.equals(selection.start.path)) {
                  return null;
                }
                final text = delta.toPlainText();
                // An example, if the text ends with 'hello', then show the autocomplete.
                if (text.toLowerCase().endsWith('hello')) {
                  return ' world';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
