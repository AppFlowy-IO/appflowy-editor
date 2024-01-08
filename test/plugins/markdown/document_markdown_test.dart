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

    test('with nested list', () {
      final markdown = documentToMarkdown(
        Document.fromJson(
          Map<String, Object>.from(json.decode(withNestedListDocument)),
        ),
      );
      expect(markdown, withNestedListMarkdown);
    });
  });
}

const withNestedListDocument =
    '''{"document":{"type":"page","children":[{"type":"numbered_list","data":{"delta":[{"insert":"number 1"}],"number":1}},{"type":"numbered_list","data":{"delta":[{"insert":"number 2"}]}},{"type":"numbered_list","data":{"delta":[{"insert":"number 3"}]}},{"type":"paragraph","data":{"delta":[]}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 1"}]}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 2"}]}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 3"}]}},{"type":"paragraph","data":{"delta":[]}},{"type":"numbered_list","children":[{"type":"numbered_list","data":{"delta":[{"insert":"number 1"}]}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 1"}]}},{"type":"todo_list","data":{"checked":false,"delta":[{"insert":"to-do list 1"}]}},{"type":"paragraph","data":{"delta":[]}}],"data":{"delta":[{"insert":"numbered list with children"}],"number":1}},{"type":"bulleted_list","children":[{"type":"numbered_list","data":{"delta":[{"insert":"number 1"}],"number":1}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 1"}]}},{"type":"todo_list","data":{"checked":false,"delta":[{"insert":"to-do list 1"}]}}],"data":{"delta":[{"insert":"bulleted list with children"}]}},{"type":"paragraph","data":{"delta":[]}},{"type":"todo_list","children":[{"type":"numbered_list","data":{"delta":[{"insert":"number 1"}],"number":1}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 1"}]}},{"type":"todo_list","data":{"checked":false,"delta":[{"insert":"to-do list 1"}]}}],"data":{"checked":false,"delta":[{"insert":"to-do list with children"}]}},{"type":"paragraph","data":{"delta":[]}},{"type":"paragraph","children":[{"type":"numbered_list","data":{"delta":[{"insert":"number 1"}]}},{"type":"bulleted_list","data":{"delta":[{"insert":"bulleted 1"}]}},{"type":"todo_list","data":{"checked":false,"delta":[{"insert":"to-do list 1"}]}}],"data":{"delta":[{"insert":"text list with children"}]}},{"type":"paragraph","data":{"delta":[]}},{"type":"paragraph","children":[{"type":"paragraph","children":[{"type":"paragraph","children":[{"type":"paragraph","data":{"delta":[{"insert":"level 4"}]}}],"data":{"delta":[{"insert":"level 3"}]}}],"data":{"delta":[{"insert":"level 2"}]}}],"data":{"delta":[{"insert":"level 1"}]}}]}}''';
const withNestedListMarkdown = '''1. number 1
1. number 2
1. number 3

* bulleted 1
* bulleted 2
* bulleted 3

1. numbered list with children
	1. number 1
	* bulleted 1
	- [ ] to-do list 1

* bulleted list with children
	1. number 1
	* bulleted 1
	- [ ] to-do list 1

- [ ] to-do list with children
	1. number 1
	* bulleted 1
	- [ ] to-do list 1

text list with children
	1. number 1
	* bulleted 1
	- [ ] to-do list 1

level 1
	level 2
		level 3
			level 4
''';

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
      {"type": "paragraph", "data":{"delta": []}},
      {"type": "divider"}
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

---
""";
