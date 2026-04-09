import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('document_markdown.dart tests', () {
    test('markdownToDocument()', () {
      final document = markdownToDocument(markdownDocument);
      final data = Map<String, Object>.from(json.decode(testDocument));

      expect(document.toJson(), data);
    });

    test('soft line break with two spaces', () {
      const markdown = 'first line  \nsecond line';
      final document = markdownToDocument(markdown);
      expect(document.root.children.length, 2);
      expect(document.root.children[0].delta?.toPlainText(), 'first line');
      expect(document.root.children[1].delta?.toPlainText(), 'second line');
    });

    test('documentToMarkdown()', () {
      final document = markdownToDocument(markdownDocument);
      final markdown = documentToMarkdown(document);

      expect(markdown, markdownDocumentEncoded);
    });

    test('paragraph + image with single \n', () {
      const markdown = '''This is the first line
![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    test('paragraph + image with double \n', () {
      const markdown = '''This is the first line

![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    test('paragraph + image without \n', () {
      const markdown =
          '''This is the first line![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    // Regression test for https://github.com/AppFlowy-IO/AppFlowy/issues/8486
    // documentToMarkdown() must not mutate the source document when processing
    // nested (indented) list items.
    test('documentToMarkdown does not orphan children of nested list items',
        () {
      final childNode = bulletedListNode(text: 'Child item');
      final parentNode = bulletedListNode(
        text: 'Parent item',
        children: [childNode],
      );
      final document = Document(root: pageNode(children: [parentNode]));

      // Verify initial structure: parent has 1 child.
      expect(document.root.children.length, 1);
      expect(document.root.children.first.children.length, 1);

      final markdown = documentToMarkdown(document);

      // The markdown output should be correct.
      expect(markdown, '* Parent item\n\t* Child item\n');

      // After conversion, the source document must be unchanged.
      // Before the fix, convertNodes() called pageNode(children: nodes) which
      // invoked unlink() on each child, removing them from their original parent.
      expect(
        document.root.children.first.children.length,
        1,
        reason:
            'documentToMarkdown() must not remove children from the source document',
      );
    });
  });
}

const testDocument = '''{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {"level": 1, "delta": [{"insert": "Heading 1"}]}
      },
      {
        "type": "heading",
        "data": {"level": 2, "delta": [{"insert": "Heading 2"}]}
      },
      {
        "type": "heading",
        "data": {"level": 3, "delta": [{"insert": "Heading 3"}]}
      },
      {"type": "divider"}
    ]
  }
}''';

const markdownDocument = """
# Heading 1
## Heading 2
### Heading 3
---""";

const markdownDocumentEncoded = """
# Heading 1
## Heading 2
### Heading 3
---
""";
