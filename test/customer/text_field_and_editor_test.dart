import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  // column
  // - text field
  // - editor

  // 1. When the text field is focused, the editor's cursor should be disabled.
  // 2. When the editor is focused, the text field's cursor should be disabled.
  // 3. Tapping a non-first line of the editor should still allow the editor to grab focus.
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('text field + editor', (tester) async {
    final widget = TextFieldAndEditor();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.tap(textField);
    await tester.pumpAndSettle();
    expect(widget.focusNode.hasFocus, true);
    expect(widget.editorFocusNode.hasFocus, false);

    final editor = find.byType(AppFlowyEditor);
    await tester.tapAt(tester.getCenter(editor));
    await tester.pumpAndSettle();
    expect(widget.focusNode.hasFocus, false);
    expect(widget.editorFocusNode.hasFocus, true);
  });

  testWidgets('text field + editor, focus issue', (tester) async {
    final editorState = EditorState.blank();
    final widget = TextFieldAndEditor(
      editorState: editorState,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    final selection = Selection.collapsed(Position(path: [0]));
    editorState.selection = selection;

    final textField = find.byType(TextField);
    await tester.tap(textField);
    await tester.pumpAndSettle();
    expect(widget.focusNode.hasFocus, true);
    expect(widget.editorFocusNode.hasFocus, false);
    expect(editorState.selection, null);

    await tester.tapAt(
      tester.getTopLeft(find.byType(ParagraphBlockComponentWidget)),
    );
    await tester.pumpAndSettle();
    expect(widget.focusNode.hasFocus, false);
    expect(widget.editorFocusNode.hasFocus, true);
    expect(editorState.selection, selection);
  });
}

class TextFieldAndEditor extends StatelessWidget {
  TextFieldAndEditor({
    super.key,
    this.editorState,
  });

  final controller = TextEditingController();
  final focusNode = FocusNode();
  final editorFocusNode = FocusNode();
  final EditorState? editorState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
              ),
              Expanded(
                child: Container(
                  width: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: AppFlowyEditor(
                    focusNode: editorFocusNode,
                    editorState: editorState ?? EditorState.blank(),
                    editorStyle: const EditorStyle.mobile(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
