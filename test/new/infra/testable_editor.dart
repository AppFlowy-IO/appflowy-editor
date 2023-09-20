import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/text_input_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../find_replace_menu/find_replace_menu_utils.dart';
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

  MockIMEInput? _ime;
  MockIMEInput get ime {
    return _ime ??= MockIMEInput(
      editorState: editorState,
      tester: tester,
    );
  }

  Future<TestableEditor> startTesting({
    Locale locale = const Locale('en'),
    bool autoFocus = false,
    bool editable = true,
    bool shrinkWrap = false,
    bool withFloatingToolbar = false,
    bool inMobile = false,
    ScrollController? scrollController,
    Widget Function(Widget child)? wrapper,
    TargetPlatform? platform,
    String? defaultTextDirection,
  }) async {
    await AppFlowyEditorLocalizations.load(locale);

    if (withFloatingToolbar) {
      scrollController ??= ScrollController();
    }

    final editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: shrinkWrap,
      scrollController: scrollController,
    );

    Widget editor = Builder(
      builder: (context) {
        return AppFlowyEditor(
          editorState: editorState,
          editable: editable,
          autoFocus: autoFocus,
          shrinkWrap: shrinkWrap,
          editorScrollController: editorScrollController,
          commandShortcutEvents: [
            ...standardCommandShortcutEvents,
            ...TestableFindAndReplaceCommands(context: context)
                .testableFindAndReplaceCommands,
          ],
          editorStyle: inMobile
              ? EditorStyle.mobile(
                  defaultTextDirection: defaultTextDirection,
                )
              : EditorStyle.desktop(
                  defaultTextDirection: defaultTextDirection,
                ),
        );
      },
    );

    if (withFloatingToolbar) {
      if (inMobile) {
        final items = [
          textDecorationMobileToolbarItem,
          headingMobileToolbarItem,
          todoListMobileToolbarItem,
          listMobileToolbarItem,
          linkMobileToolbarItem,
          quoteMobileToolbarItem,
          codeMobileToolbarItem,
        ];
        editor = Column(
          children: [
            Expanded(
              child: AppFlowyEditor(
                editorStyle: const EditorStyle.mobile(),
                editorState: editorState,
              ),
            ),
            MobileToolbar(
              editorState: editorState,
              toolbarItems: items,
            ),
          ],
        );
      } else {
        editor = FloatingToolbar(
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
          ],
          editorState: editorState,
          editorScrollController: editorScrollController,
          child: editor,
        );
      }
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppFlowyEditorLocalizations.delegate,
        ],
        supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
        locale: locale,
        home: Scaffold(
          body: wrapper == null
              ? editor
              : wrapper(
                  editor,
                ),
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

  void initializeWithDocument(Document document) {
    _editorState = EditorState(
      document: document,
    );
  }

  Future<void> dispose() async {
    _ime = null;
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
    _editorState.updateSelectionWithReason(
      selection,
      reason: SelectionUpdateReason.uiEvent,
    );
    await tester.pumpAndSettle();
  }

  Node? nodeAtPath(Path path) {
    return _editorState.getNodeAtPath(path);
  }

  final keyToCharacterMap = {
    LogicalKeyboardKey.space: ' ',
    LogicalKeyboardKey.backquote: '`',
    LogicalKeyboardKey.tilde: '~',
    LogicalKeyboardKey.asterisk: '*',
    LogicalKeyboardKey.underscore: '_',
  };
  Future<void> pressKey({
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
      if (keyToCharacterMap.containsKey(key)) {
        final character = keyToCharacterMap[key]!;
        await ime.typeText(character);
      } else {
        await simulateKeyDownEvent(key);
        await simulateKeyUpEvent(key);
      }
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
    } else if (character != null) {
      await ime.typeText(character);
    }
    await tester.pumpAndSettle();
  }
}

extension TestableEditorExtension on WidgetTester {
  TestableEditor get editor => TestableEditor(tester: this)..initialize();

  EditorState get editorState => editor.editorState;
}

class MockIMEInput {
  MockIMEInput({
    required this.editorState,
    required this.tester,
  });

  final EditorState editorState;
  final WidgetTester tester;

  TextInputService get imeInput {
    final keyboardService = tester.state(find.byType(KeyboardServiceWidget))
        as KeyboardServiceWidgetState;
    return keyboardService.textInputService;
  }

  Future<void> typeText(String text) async {
    final selection = editorState.selection;
    if (selection == null) {
      return;
    }
    // if the selection is collapsed, do insertion.
    //  else if the selection is not collapsed, do replacement.
    if (selection.isCollapsed) {
      await insertText(text);
    } else {
      await replaceText(text);
    }
  }

  Future<void> insertText(String text) async {
    final selection = editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = editorState.getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (delta == null) {
      return;
    }
    await imeInput.apply([
      TextEditingDeltaInsertion(
        oldText: ' ${delta.toPlainText()}', // TODO: fix this workaround
        textInserted: text,
        insertionOffset: selection.startIndex + 1,
        selection: TextSelection.collapsed(
          offset: selection.startIndex + 1 + text.length,
        ),
        composing: TextRange.empty,
      ),
    ]);
    await tester.pumpAndSettle();
  }

  Future<void> replaceText(String text) async {
    var selection = editorState.selection?.normalized;
    if (selection == null) {
      return;
    }
    if (!selection.isSingle || !selection.isCollapsed) {
      await editorState.deleteSelection(selection);
    }
    selection = editorState.selection?.normalized;
    if (selection == null) {
      return;
    }

    final oldText =
        editorState.getNodeAtPath(selection.start.path)!.delta!.toPlainText();

    await imeInput.apply([
      TextEditingDeltaReplacement(
        oldText: ' $oldText',
        replacementText: text,
        replacedRange: TextSelection(
          baseOffset: selection.startIndex + 1,
          extentOffset: selection.endIndex + 1,
        ),
        selection: TextSelection.collapsed(
          offset: selection.startIndex + 1 + text.length,
        ),
        composing: TextRange.empty,
      ),
    ]);
    await tester.pumpAndSettle();
  }
}
