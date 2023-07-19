import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<HTMLNodeParser> parser = [
    const HtmlTextNodeParser(),
    const HtmlBulletedListNodeParser(),
    const HtmlNumberedListNodeParser(),
    const HtmlTodoListNodeParser(),
    const HtmlQuoteNodeParser(),
    const HtmlHeadingNodeParser(),
    const HtmlImageNodeParser(),
  ];
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
          const HtmlHeadingNodeParser()
              .transformNodeToHTMLString(node, encodeParsers: parser),
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
        const HtmlBulletedListNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
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
        const HtmlNumberedListNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
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
        const HtmlTodoListNodeParser()
            .transformNodeToHTMLString(checkedNode, encodeParsers: parser),
        '<div>Welcome to AppFlowy<input type="checkbox" checked="true"></div>',
      );
      expect(
        const HtmlTodoListNodeParser()
            .transformNodeToHTMLString(uncheckedNode, encodeParsers: parser),
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
        const HtmlQuoteNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
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
        const HtmlTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        "<p><strong>Welcome to AppFlowy</strong></p>",
      );
    });
  });
}
