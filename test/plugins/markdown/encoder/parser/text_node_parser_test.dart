import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('text_node_parser.dart', () {
    const text = 'Welcome to AppFlowy';

    test('heading style', () {
      for (var i = 1; i <= 6; i++) {
        final node = headingNode(
          level: i,
          attributes: {
            'delta': (Delta()..insert(text)).toJson(),
          },
        );
        expect(
          const HeadingNodeParser().transform(node, null),
          '${'#' * i} $text',
        );
      }
    });

    test('bulleted list style', () {
      final node = bulletedListNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(const BulletedListNodeParser().transform(node, null), '* $text\n');
    });

    test('numbered list style', () {
      final node = numberedListNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const NumberedListNodeParser().transform(node, null),
        '1. $text\n',
      );
    });

    test('todo list style', () {
      final checkedNode = todoListNode(
        checked: true,
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      final uncheckedNode = todoListNode(
        checked: false,
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const TodoListNodeParser().transform(checkedNode, null),
        '- [x] $text\n',
      );
      expect(
        const TodoListNodeParser().transform(uncheckedNode, null),
        '- [ ] $text\n',
      );
    });

    test('quote style', () {
      final node = quoteNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(const QuoteNodeParser().transform(node, null), '> $text\n');
    });

    test('code block style', () {
      final node = Node(
        type: 'code',
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const CodeBlockNodeParser().transform(node, null),
        '```\n$text\n```',
      );
    });

    test('fallback', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
          'bold': true,
        },
      );
      expect(const TextNodeParser().transform(node, null), '$text\n');
    });
  });
}
