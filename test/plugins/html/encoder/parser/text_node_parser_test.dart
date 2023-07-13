import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('html_text_node_parser.dart', () {
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
          const HtmlHeadingNodeParser().transform(node),
          '<h$i>Welcome to AppFlowy</h$i>',
        );
      }
    });

    test('bulleted list style', () {
      final node = bulletedListNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const HtmlBulletedListNodeParser().transform(node),
        '<ul><li>Welcome to AppFlowy</li></ul>',
      );
    });

    test('numbered list style', () {
      final node = numberedListNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const HtmlNumberedListNodeParser().transform(node),
        '<ol><li>Welcome to AppFlowy</li></ol>',
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
        const HtmlTodoListNodeParser().transform(checkedNode),
        '<div>Welcome to AppFlowy<input type="checkbox" checked="true"></div>',
      );
      expect(
        const HtmlTodoListNodeParser().transform(uncheckedNode),
        '<div>Welcome to AppFlowy<input type="checkbox" checked="false"></div>',
      );
    });

    test('quote style', () {
      final node = quoteNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const HtmlQuoteNodeParser().transform(node),
        '<blockquote>Welcome to AppFlowy</blockquote>',
      );
    });

    test('fallback', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'bold': true,
                  },
                ))
              .toJson(),
        },
      );
      expect(
        const HtmlTextNodeParser().transform(node),
        "<p><strong>Welcome to AppFlowy</strong></p>",
      );
    });
  });
}
