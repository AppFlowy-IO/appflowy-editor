import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/testable_editor.dart';

class TextDirectionTest with BlockComponentTextDirectionMixin {
  TextDirectionTest({
    required this.node,
    String? defaultTextDirection,
  }) {
    editorState.editorStyle =
        EditorStyle.desktop(defaultTextDirection: defaultTextDirection);
  }

  @override
  final Node node;

  @override
  final EditorState editorState = EditorState.blank(withInitialText: false);
}

void main() {
  group('text_direction_mixin', () {
    test('rtl', () {
      final node = paragraphNode(
        text: 'Hello',
        textDirection: blockComponentTextDirectionRTL,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.rtl);
    });

    test('ltr', () {
      final node = paragraphNode(
        text: 'Hello',
        textDirection: blockComponentTextDirectionLTR,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.ltr);
    });

    test('fallback to layout direction', () {
      final node = paragraphNode(
        text: 'سلام',
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.ltr);
    });

    test('fallback to default text direction', () {
      final node = paragraphNode(
        text: 'سلام',
      );
      final direction =
          TextDirectionTest(node: node, defaultTextDirection: "rtl")
              .calculateTextDirection();
      expect(direction, TextDirection.rtl);
    });

    test('fallback to default text direction auto', () {
      final node = paragraphNode(
        text: 'سلام',
      );
      final direction =
          TextDirectionTest(node: node, defaultTextDirection: "auto")
              .calculateTextDirection();
      expect(direction, TextDirection.rtl);
    });

    test('if not auto don\'t fallback to last direction', () {
      final node = paragraphNode(
        text: 'سلام',
      );
      final textDirectionTest =
          TextDirectionTest(node: node, defaultTextDirection: "rtl");
      textDirectionTest.lastDirection = TextDirection.ltr;
      final direction = textDirectionTest.calculateTextDirection();
      expect(direction, TextDirection.rtl);
    });

    test('auto empty text', () {
      final node = paragraphNode(
        text: '',
        textDirection: blockComponentTextDirectionAuto,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.ltr);
    });

    test('auto empty text with last direction', () {
      final node = paragraphNode(
        text: '',
        textDirection: blockComponentTextDirectionAuto,
      );
      final textDirectionTest = TextDirectionTest(node: node);
      textDirectionTest.lastDirection = TextDirection.rtl;
      final direction = textDirectionTest.calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );
      expect(direction, TextDirection.rtl);
    });

    test('auto ltr text', () {
      final node = paragraphNode(
        text: 'Hello',
        textDirection: blockComponentTextDirectionAuto,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.ltr);
    });

    test('auto rtl text', () {
      final node = paragraphNode(
        text: 'سلام',
        textDirection: blockComponentTextDirectionAuto,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.rtl);
    });

    test('auto mixed text', () {
      final tests = [
        {'text': 'aس', 'exp': TextDirection.ltr},
        {'text': 'سa', 'exp': TextDirection.rtl},
        {'text': '1س', 'exp': TextDirection.ltr},
        {'text': '۱a', 'exp': TextDirection.rtl},
        {'text': ' س', 'exp': TextDirection.rtl},
        {'text': '!س', 'exp': TextDirection.rtl},
        {'text': '! a', 'exp': TextDirection.ltr},
      ];

      for (var i = 0; i < tests.length; i++) {
        final node = paragraphNode(
          text: tests[i]['text'].toString(),
          textDirection: blockComponentTextDirectionAuto,
        );
        final direction =
            TextDirectionTest(node: node).calculateTextDirection();
        expect(
          direction,
          tests[i]['exp'],
          reason: 'Test $i: text="${tests[i]['text']}"',
        );
      }
    });

    test('auto empty text use previous node direction', () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: blockComponentTextDirectionRTL,
          ),
          paragraphNode(
            text: '\$',
            textDirection: blockComponentTextDirectionAuto,
          ),
        ],
      );
      final direction =
          TextDirectionTest(node: node.children.last).calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );
      expect(direction, TextDirection.rtl);
    });

    test('use previous node direction (rtl) only when current is auto', () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: blockComponentTextDirectionRTL,
          ),
          paragraphNode(
            text: '\$',
          ),
        ],
      );
      final direction =
          TextDirectionTest(node: node.children.last).calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );
      expect(direction, TextDirection.ltr);
    });

    test(
        'auto empty text don\'t use previous node direction because we can determine by the node text',
        () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: blockComponentTextDirectionRTL,
          ),
          paragraphNode(
            text: 'Hello',
            textDirection: blockComponentTextDirectionAuto,
          ),
        ],
      );
      final direction =
          TextDirectionTest(node: node.children.last).calculateTextDirection(
        layoutDirection: TextDirection.rtl,
      );
      expect(direction, TextDirection.ltr);
    });

    test(
        'auto empty text don\'t use previous node direction when we have last direction',
        () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: blockComponentTextDirectionRTL,
          ),
          paragraphNode(
            text: '',
            textDirection: blockComponentTextDirectionAuto,
          ),
        ],
      );

      final textDirectionTest = TextDirectionTest(node: node.children.last);
      textDirectionTest.lastDirection = TextDirection.ltr;

      final direction = textDirectionTest.calculateTextDirection(
        layoutDirection: TextDirection.rtl,
      );
      expect(direction, TextDirection.ltr);
    });

    test('auto empty text previous node direction null', () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            attributes: {blockComponentTextDirection: null},
          ),
          paragraphNode(
            text: '\$',
            textDirection: blockComponentTextDirectionAuto,
          ),
        ],
      );

      final direction =
          TextDirectionTest(node: node.children.last).calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );

      expect(direction, TextDirection.ltr);
    });

    test('auto empty text use parent node direction', () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: "rtl",
            children: [
              paragraphNode(
                text: '\$',
                textDirection: blockComponentTextDirectionAuto,
              ),
            ],
          ),
        ],
      );

      final direction =
          TextDirectionTest(node: node.children.first.children.last)
              .calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );

      expect(direction, TextDirection.rtl);
    });

    test(
        'auto empty text use parent node direction even if previous node has no direction attribute',
        () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: "rtl",
            children: [
              paragraphNode(
                text: 'سلام',
              ),
              paragraphNode(
                text: '\$',
                textDirection: blockComponentTextDirectionAuto,
              ),
            ],
          ),
        ],
      );

      final direction =
          TextDirectionTest(node: node.children.first.children.last)
              .calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );

      expect(direction, TextDirection.rtl);
    });

    test('auto empty text don\'t use previous node if its not just before node',
        () {
      final node = pageNode(
        children: [
          paragraphNode(
            text: 'سلام',
            textDirection: "rtl",
          ),
          paragraphNode(
            text: 'سلام',
          ),
          paragraphNode(
            text: '\$',
            textDirection: blockComponentTextDirectionAuto,
          ),
        ],
      );

      final direction =
          TextDirectionTest(node: node.children.last).calculateTextDirection(
        layoutDirection: TextDirection.ltr,
      );

      expect(direction, TextDirection.ltr);
    });
  });

  group('text_direction_mixin - widget test', () {
    testWidgets('use previous node direction (auto) calculated value (rtl)',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: 'سلام',
            textDirection: blockComponentTextDirectionAuto,
          ),
        )
        ..addNode(
          paragraphNode(
            text: '\$',
            textDirection: blockComponentTextDirectionAuto,
          ),
        );
      await editor.startTesting();

      final node = editor.nodeAtPath([1])!;
      expect(node.selectable?.textDirection(), TextDirection.rtl);

      await editor.dispose();
    });

    testWidgets(
        'use previous node direction calculated value (rtl) when its set by default text direction',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: 'سلام',
          ),
        )
        ..addNode(
          paragraphNode(
            text: '\$',
          ),
        );
      await editor.startTesting(
        defaultTextDirection: blockComponentTextDirectionAuto,
      );

      final node = editor.nodeAtPath([1])!;
      expect(node.selectable?.textDirection(), TextDirection.rtl);

      await editor.dispose();
    });

    testWidgets('indent padding on rtl direction', (tester) async {
      final node = paragraphNode(
        text: 'سلام',
        textDirection: blockComponentTextDirectionRTL,
        children: [
          paragraphNode(
            text: 'س',
            textDirection: blockComponentTextDirectionRTL,
          )
        ],
      );
      final editor = tester.editor..addNode(node);
      await editor.startTesting();

      final nestedBlock =
          node.key.currentState as NestedBlockComponentStatefulWidgetMixin;

      expect(
        nestedBlock.indentPadding,
        const BlockComponentConfiguration()
            .indentPadding(node, TextDirection.rtl),
      );

      await editor.dispose();
    });

    testWidgets('indent padding on fallback to default direction auto',
        (tester) async {
      final node = paragraphNode(
        text: 'سلام',
        children: [paragraphNode(text: 'س')],
      );
      final editor = tester.editor..addNode(node);
      await editor.startTesting(
        defaultTextDirection: blockComponentTextDirectionAuto,
      );

      final nestedBlock =
          node.key.currentState as NestedBlockComponentStatefulWidgetMixin;

      expect(
        nestedBlock.indentPadding,
        const BlockComponentConfiguration()
            .indentPadding(node, TextDirection.rtl),
      );

      await editor.dispose();
    });

    testWidgets('indent padding respect last direction', (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: 'سلام',
            children: [paragraphNode()],
          ),
        );
      await editor.startTesting(
        defaultTextDirection: blockComponentTextDirectionAuto,
      );

      final node = editor.editorState.getNodeAtPath([0])!;

      var nestedBlock =
          node.key.currentState as NestedBlockComponentStatefulWidgetMixin;
      expect(
        nestedBlock.indentPadding,
        const BlockComponentConfiguration()
            .indentPadding(node, TextDirection.rtl),
      );

      final selection = Selection.single(path: [0, 0], startOffset: 0);
      await editor.updateSelection(selection);
      await editor.ime.typeText('a');

      nestedBlock =
          node.key.currentState as NestedBlockComponentStatefulWidgetMixin;
      expect(
        nestedBlock.indentPadding,
        const BlockComponentConfiguration()
            .indentPadding(node, TextDirection.ltr),
      );

      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      nestedBlock =
          node.key.currentState as NestedBlockComponentStatefulWidgetMixin;
      expect(
        nestedBlock.indentPadding,
        const BlockComponentConfiguration()
            .indentPadding(node, TextDirection.ltr),
      );

      await editor.dispose();
    });
  });
}
