import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/html/encoder/parser/divider_node_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<HTMLNodeParser> parser = [
    const HTMLTextNodeParser(),
    const HTMLBulletedListNodeParser(),
    const HTMLNumberedListNodeParser(),
    const HTMLTodoListNodeParser(),
    const HTMLQuoteNodeParser(),
    const HTMLHeadingNodeParser(),
    const HTMLImageNodeParser(),
    const HtmlTableNodeParser(),
    const HTMLDividerNodeParser(),
  ];
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
          const HTMLHeadingNodeParser()
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
        const HTMLBulletedListNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '<ul><li>Welcome to AppFlowy</li></ul>',
      );
    });

    test('empty line', () {
      final node = paragraphNode(
        attributes: {
          'delta': [],
        },
      );
      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '<br>',
      );
    });

    test('numbered list style', () {
      final node = numberedListNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const HTMLNumberedListNodeParser()
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
        const HTMLTodoListNodeParser()
            .transformNodeToHTMLString(checkedNode, encodeParsers: parser),
        '<div><input type="checkbox" checked="">Welcome to AppFlowy</div>',
      );
      expect(
        const HTMLTodoListNodeParser()
            .transformNodeToHTMLString(uncheckedNode, encodeParsers: parser),
        '<div><input type="checkbox">Welcome to AppFlowy</div>',
      );
    });

    test('quote style', () {
      final node = quoteNode(
        attributes: {
          'delta': (Delta()..insert(text)).toJson(),
        },
      );
      expect(
        const HTMLQuoteNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '<blockquote>Welcome to AppFlowy</blockquote>',
      );
    });

    test('divider', () {
      final node = dividerNode();
      expect(
        const HTMLDividerNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '<hr>',
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
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        "<p><strong>Welcome to AppFlowy</strong></p>",
      );
    });
    test('underline', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'underline': true,
                  },
                ))
              .toJson(),
        },
      );

      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        "<p><u>Welcome to AppFlowy</u></p>",
      );
    });
    test('strikethrough', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'strikethrough': true,
                  },
                ))
              .toJson(),
        },
      );

      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        "<p><del>Welcome to AppFlowy</del></p>",
      );
    });
    test('underline and strikethrough', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'strikethrough': true,
                    'underline': true,
                  },
                ))
              .toJson(),
        },
      );

      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '''<p><span style="text-decoration: underline line-through">Welcome to AppFlowy</span></p>''',
      );
    });
    test('multiple attributes Test with background and text color', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'bold': true,
                    'italic': true,
                    "underline": true,
                    "strikethrough": true,
                    "bg_color": "0x6000bcf0",
                    "font_color": "0xff2196f3",
                  },
                ))
              .toJson(),
        },
      );

      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '''<p><span style="font-weight: bold; text-decoration: underline line-through; font-style: italic; background-color: rgba(0, 188, 240, 96); color: rgba(33, 150, 243, 255)">Welcome to AppFlowy</span></p>''',
      );
    });
    test('multiple attributes Test with background', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'bold': true,
                    'italic': true,
                    "underline": true,
                    "strikethrough": true,
                    "bg_color": "0x6000bcf0",
                  },
                ))
              .toJson(),
        },
      );

      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '''<p><span style="font-weight: bold; text-decoration: underline line-through; font-style: italic; background-color: rgba(0, 188, 240, 96)">Welcome to AppFlowy</span></p>''',
      );
    });
    test('multiple attributes Test with text color', () {
      final node = paragraphNode(
        attributes: {
          'delta': (Delta()
                ..insert(
                  text,
                  attributes: {
                    'bold': true,
                    'italic': true,
                    "underline": true,
                    "strikethrough": true,
                    "font_color": "0xff2196f3",
                  },
                ))
              .toJson(),
        },
      );
      expect(
        const HTMLTextNodeParser()
            .transformNodeToHTMLString(node, encodeParsers: parser),
        '''<p><span style="font-weight: bold; text-decoration: underline line-through; font-style: italic; color: rgba(33, 150, 243, 255)">Welcome to AppFlowy</span></p>''',
      );
    });
  });
}
