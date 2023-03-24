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

    test('documentToMarkdown()', () {
      final document = markdownToDocument(markdownDocument);
      final markdown = documentToMarkdown(document);

      expect(markdown, markdownDocumentEncoded);
    });
  });
}

const testDocument = '''{
  "document": {
    "type": "editor",
    "children": [
      {
        "type": "text",
        "attributes": {"subtype": "heading", "heading": "h1"},
        "delta": [{"insert": "Heading 1"}]
      },
      {
        "type": "text",
        "attributes": {"subtype": "heading", "heading": "h2"},
        "delta": [{"insert": "Heading 2"}]
      },
      {
        "type": "text",
        "attributes": {"subtype": "heading", "heading": "h3"},
        "delta": [{"insert": "Heading 3"}]
      },
      {"type": "text", "delta": []},
      {"type": "divider"},
      {"type": "text", "delta": [{"insert": ""}]}
    ]
  }
}''';

const markdownDocument = """# Heading 1
## Heading 2
### Heading 3

---""";

const markdownDocumentEncoded = """# Heading 1
## Heading 2
### Heading 3

""";
