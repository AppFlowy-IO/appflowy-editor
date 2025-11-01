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

test('image inside paragraph (no spacing)', () {
  const markdown = 'Text before![img](https://example.com/image.png)text after.';
  final document = markdownToDocument(markdown);
  final nodes = document.root.children;
  expect(nodes.length, 3);
  expect(nodes[0].delta?.toPlainText(), 'Text before');
  expect(nodes[1].attributes['url'], 'https://example.com/image.png');
  expect(nodes[2].delta?.toPlainText(), 'text after.');
});

test('image between two paragraphs (no blank lines)', () {
  const markdown = 'First paragraph.\n![img](https://example.com/image.png)\nSecond paragraph.';
  final document = markdownToDocument(markdown);
  final nodes = document.root.children;
  expect(nodes.length, 3);
  expect(nodes[0].delta?.toPlainText(), 'First paragraph.');
  expect(nodes[1].attributes['url'], 'https://example.com/image.png');
  expect(nodes[2].delta?.toPlainText(), 'Second paragraph.');
});

test('multiple images on same line (inline)', () {
  const markdown = '![img1](https://example.com/image.png) ![img2](https://example.com/image.png)![img3](https://example.com/image.png)';
  final document = markdownToDocument(markdown);
  final nodes = document.root.children;
  expect(nodes.length, 3);
  expect(nodes[0].attributes['url'], 'https://example.com/image.png');
  expect(nodes[1].attributes['url'], 'https://example.com/image.png');
  expect(nodes[2].attributes['url'], 'https://example.com/image.png');
});

test('image attached directly to previous content (no newline or space)', () {
  const markdown = 'Paragraph![img](https://example.com/image.png)';
  final document = markdownToDocument(markdown);
  final nodes = document.root.children;
  expect(nodes.length, 2);
  expect(nodes[0].delta?.toPlainText(), 'Paragraph');
  expect(nodes[1].attributes['url'], 'https://example.com/image.png');
});

test('image attached directly to next content (no newline)', () {
  const markdown = '![img](https://example.com/image.png)This is a sentence.';
  final document = markdownToDocument(markdown);
  final nodes = document.root.children;
  expect(nodes.length, 2);
  expect(nodes[0].attributes['url'], 'https://example.com/image.png');
  expect(nodes[1].delta?.toPlainText(), 'This is a sentence.');
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
