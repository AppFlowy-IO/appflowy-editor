import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/util/document_util.dart';

void main() {
  group('getDeltaAttributesInSelectionStart()', () {
    test('Returns null if missing selection', () {
      final document = Document.blank();
      final editorState = EditorState(document: document);
      final attributes = editorState.getDeltaAttributesInSelectionStart();
      expect(attributes, isNull);
    });

    test('Returns null if selected node does not exist (delta == null)', () {
      final document = Document.blank();
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 3,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart();
      expect(attributes, isNull);
    });

    test('Returns null if there are no attributes', () {
      final document = Document.blank()..addParagraph(initialText: 'Hello');
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 2,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart();
      expect(attributes, isNull);
    });

    test(
        'Returns null if selection collapsed at the beginning of formatted text',
        () {
      final editorState = EditorState(document: formattedDocument);
      editorState.selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 0,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart();

      expect(attributes, isNull);
    });

    test('Returns null if selection collapsed at the end of formatted text',
        () {
      expect(
        (formattedDocument.first!.delta!.first as TextInsert).text,
        equals(headingText),
      );

      final editorState = EditorState(document: formattedDocument);
      editorState.selection = Selection.collapsed(
        Position(
          path: [0],
          offset: headingText.length,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart();

      expect(attributes, isNull);
    });

    test('Returns all attributes in default selection', () {
      final editorState = EditorState(document: formattedDocument);
      final attributes = editorState.getDeltaAttributesInSelectionStart(
        Selection(
          start: Position(
            path: [1],
            offset: 3,
          ),
          end: Position(
            path: [1],
            offset: 7,
          ),
        ),
      );

      expect(attributes, isNotNull);

      expect(attributes, containsPair('bold', true));
      expect(attributes, containsPair('some', 'thing'));
      expect(attributes, containsPair('color', '#888'));
    });

    test('Returns first node\'s attributes if selection spans multiple nodes',
        () {
      final editorState = EditorState(document: formattedDocument);
      editorState.selection = Selection(
        start: Position(
          path: [0],
          offset: 3,
        ),
        end: Position(
          path: [1],
          offset: 2,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart();

      expect(attributes, isNotNull);
      expect(attributes, containsPair('bold', true));
      expect(attributes, containsPair('italic', true));
    });

    test('Returns attributes for given selection argument', () {
      final document = formattedDocument;
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        // Select Node 2
        Position(
          path: [1],
          offset: 3,
        ),
      );
      final attributes = editorState.getDeltaAttributesInSelectionStart(
        Selection.collapsed(
          // Select Node 1
          Position(
            path: [0],
            offset: 3,
          ),
        ),
      );
      expect(attributes, isNotNull);
      expect(attributes, containsPair('bold', true));
      expect(attributes, containsPair('italic', true));
    });
  });
}

const headingText = "Hello World!";
final formattedDocument = Document.fromJson(
  {
    "document": {
      "type": "page",
      "children": [
        // Node 1
        {
          "type": "heading",
          "data": {
            "level": 2,
            "delta": [
              {
                "insert": headingText,
                "attributes": {"bold": true, "italic": true},
              },
            ],
          },
        },
        // Node 2
        {
          "type": "paragraph",
          "data": {
            "delta": [
              // Operation 1
              {
                "insert": "01234",
                "attributes": {"bold": true, "color": "#888", "some": "thing"},
              },
              // Operation 2
              {
                "insert": "5678",
                "attributes": {"bold": false, "anything": "else"},
              },
            ],
          },
        },
      ],
    },
  },
);
