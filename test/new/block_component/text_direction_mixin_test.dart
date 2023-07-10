import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TextDirectionTest with BlockComponentTextDirectionMixin {
  TextDirectionTest({
    required this.node,
  });

  @override
  final Node node;
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

    test('auto empty text', () {
      final node = paragraphNode(
        text: '',
        textDirection: blockComponentTextDirectionAuto,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection();
      expect(direction, TextDirection.ltr);
    });

    test('auto empty text with lastDirection', () {
      final node = paragraphNode(
        text: '',
        textDirection: blockComponentTextDirectionAuto,
      );
      final direction = TextDirectionTest(node: node).calculateTextDirection(
        defaultTextDirection: TextDirection.rtl,
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
  });
}
