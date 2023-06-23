import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dirKey = FlowyRichTextKeys.dir;
  group('GetNodeDirection::', () {
    test('rtl', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.rtl.name,
        },
      );

      final (direction, str) = getNodeDirection(node);
      expect(direction, TextDirection.rtl);
      expect(str, null);
    });

    test('ltr', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.ltr.name,
        },
      );

      final (direction, str) = getNodeDirection(node);
      expect(direction, TextDirection.ltr);
      expect(str, null);
    });

    test('auto empty text', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.auto.name,
        },
      );

      final (direction, str) = getNodeDirection(node);
      expect(direction, TextDirection.ltr);
      expect(str, null);
    });

    test('auto empty text with lastDirection', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.auto.name,
        },
      );

      final (direction, str) = getNodeDirection(node, '', TextDirection.rtl);
      expect(direction, TextDirection.rtl);
      expect(str, null);
    });

    test('auto ltr text', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.auto.name,
          ParagraphBlockKeys.delta: (Delta()..insert('Hello')).toJson(),
        },
      );

      final (direction, str) = getNodeDirection(node);
      expect(direction, TextDirection.ltr);
      expect(str, 'H');
    });

    test('auto rtl text', () {
      final node = Node(
        type: 'example',
        attributes: {
          dirKey: FlowyTextDirection.auto.name,
          ParagraphBlockKeys.delta: (Delta()..insert('سلام')).toJson(),
        },
      );

      final (direction, str) = getNodeDirection(node);
      expect(direction, TextDirection.rtl);
      expect(str, 'س');
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
        final node = Node(
          type: 'example',
          attributes: {
            dirKey: FlowyTextDirection.auto.name,
            ParagraphBlockKeys.delta:
                (Delta()..insert(tests[i]['text'].toString())).toJson(),
          },
        );

        final (direction, _) = getNodeDirection(node);
        expect(direction, tests[i]['exp'],
            reason: 'Test ${i}: text="${tests[i]['text']}"');
      }
    });

    test('auto last start text test', () {
      final tests = [
        {'text': 'aس', 'exp': 'a'},
        {'text': 'سa', 'exp': 'س'},
        {'text': '1س', 'exp': '1'},
        {'text': '۱a', 'exp': '۱'},
        {'text': ' س', 'exp': ' س'},
        {'text': '!س', 'exp': '!س'},
        {'text': '! a', 'exp': '! a'},
      ];

      for (var i = 0; i < tests.length; i++) {
        final node = Node(
          type: 'example',
          attributes: {
            dirKey: FlowyTextDirection.auto.name,
            ParagraphBlockKeys.delta:
                (Delta()..insert(tests[i]['text'].toString())).toJson(),
          },
        );

        final (_, lastStartText) = getNodeDirection(node);
        expect(lastStartText, tests[i]['exp'],
            reason: 'Test ${i}: text="${tests[i]['text']}"');
      }
    });
  });
}
