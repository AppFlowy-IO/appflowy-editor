import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

class TestableEditor {
  TestableEditor({
    required this.tester,
  });

  final WidgetTester tester;

  EditorState get editorState => _editorState;
  late EditorState _editorState;

  Document get document => _editorState.document;
  int get documentRootLen => document.root.children.length;

  Selection? get selection => _editorState.selection;

  Future<TestableEditor> startTesting({
    Locale locale = const Locale('en'),
  }) async {
    final editor = AppFlowyEditor(
      editorState: editorState,
      blockComponentBuilders: {
        'document': DocumentComponentBuilder(),
        'paragraph': TextBlockComponentBuilder(),
        'todo_list': TodoListBlockComponentBuilder(),
        'bulleted_list': BulletedListBlockComponentBuilder(),
        'numbered_list': NumberedListBlockComponentBuilder(),
        'quote': QuoteBlockComponentBuilder(),
        'heading': HeadingBlockComponentBuilder(),
      },
      characterShortcutEvents: [
        insertNewLine,
        formatAsteriskToBulletedList,
        formatMinusToBulletedList,
        formatNumberToNumberedList,
        formatGreaterToQuote,
        formatSignToHeading,
        slashCommand,
        formatUnderscoreToItalic,
      ],
      commandShortcutEvents: [
        backspaceCommand,
        ...arrowLeftKeys,
        ...arrowRightKeys,
        ...arrowUpKeys,
        ...arrowDownKeys,
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppFlowyEditorLocalizations.delegate,
        ],
        supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
        locale: locale,
        home: Scaffold(
          body: editor,
        ),
      ),
    );
    await tester.pump();
    return this;
  }

  void initialize() {
    _editorState = EditorState(
      document: Document.blank(),
    );
  }

  Future<void> dispose() async {
    // Workaround: to wait all the debounce calls expire.
    //  https://github.com/flutter/flutter/issues/11181#issuecomment-568737491
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  void addNode(Node node) {
    _editorState.document.root.insert(node);
  }

  void addParagraph({
    TextBuilder? builder,
    String? initialText,
    NodeDecorator? decorator,
  }) {
    addParagraphs(
      1,
      builder: builder,
      initialText: initialText,
      decorator: decorator,
    );
  }

  void addParagraphs(
    int count, {
    TextBuilder? builder,
    String? initialText,
    NodeDecorator? decorator,
  }) {
    _editorState.document.addParagraphs(
      count,
      builder: builder,
      initialText: initialText,
      decorator: decorator,
    );
  }

  void addEmptyParagraph() {
    _editorState.document.addParagraph(initialText: '');
  }

  Future<void> updateSelection(Selection? selection) async {
    _editorState.selection = selection;
    await tester.pumpAndSettle();
  }

  Node? nodeAtPath(Path path) {
    return _editorState.getNodeAtPath(path);
  }

  Future<void> pressLogicKey({
    String? character,
    LogicalKeyboardKey? key,
    bool isControlPressed = false,
    bool isShiftPressed = false,
    bool isAltPressed = false,
    bool isMetaPressed = false,
  }) async {
    if (key != null) {
      if (isControlPressed) {
        await simulateKeyDownEvent(LogicalKeyboardKey.control);
      }
      if (isShiftPressed) {
        await simulateKeyDownEvent(LogicalKeyboardKey.shift);
      }
      if (isAltPressed) {
        await simulateKeyDownEvent(LogicalKeyboardKey.alt);
      }
      if (isMetaPressed) {
        await simulateKeyDownEvent(LogicalKeyboardKey.meta);
      }
      await simulateKeyDownEvent(key);
      if (isControlPressed) {
        await simulateKeyUpEvent(LogicalKeyboardKey.control);
      }
      if (isShiftPressed) {
        await simulateKeyUpEvent(LogicalKeyboardKey.shift);
      }
      if (isAltPressed) {
        await simulateKeyUpEvent(LogicalKeyboardKey.alt);
      }
      if (isMetaPressed) {
        await simulateKeyUpEvent(LogicalKeyboardKey.meta);
      }
    }
    await tester.pumpAndSettle();
  }
}

extension TestableEditorExtension on WidgetTester {
  TestableEditor get editor => TestableEditor(tester: this)..initialize();

  EditorState get editorState => editor.editorState;
}
