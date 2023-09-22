import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('customize highlight color', (tester) async {
    const text = 'Hello World';
    final document = Document.blank()
      ..insert(
        [0],
        [bulletedListNode(text: text)],
      );
    final editorState = EditorState(document: document);
    final widget = CustomToolbarItemColor(
      editorState: editorState,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    // update selection and show the toolbar
    editorState.updateSelectionWithReason(
      Selection.single(path: [0], startOffset: 0, endOffset: text.length),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(FloatingToolbar), findsOneWidget);
    final bulletedListItem = tester.widget<SVGIconItemWidget>(
      find.byType(SVGIconItemWidget),
    );
    expect(bulletedListItem.highlightColor, Colors.green);
  });
}

class CustomToolbarItemColor extends StatelessWidget {
  CustomToolbarItemColor({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: FloatingToolbar(
              items: [bulletedListItem],
              style: const FloatingToolbarStyle(
                backgroundColor: Colors.red,
                toolbarActiveColor: Colors.green,
              ),
              editorState: editorState,
              editorScrollController: EditorScrollController(
                editorState: editorState,
                scrollController: scrollController,
              ),
              child: AppFlowyEditor(
                editorState: editorState,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
