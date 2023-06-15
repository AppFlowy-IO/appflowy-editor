import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'dart:developer';
import 'package:collection/collection.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('copy_event_hanndler_text.dart', () {
    test('document_copy_handler_test', () async {
      // Arrange
      final editorState = EditorState(document: Document.fromJson(data));
      // Set up a non-collapsed selection
      final firstSelectable = editorState.document.root.children
          .firstWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      final lastSelectable = editorState.document.root.children
          .lastWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      if (firstSelectable == null || lastSelectable == null) {
        return;
      }
      editorState.updateSelectionWithReason(
        Selection(start: firstSelectable.start(), end: lastSelectable.end()),
      );

      // Act
      _handleCopy(editorState);

      // Assert
      // Verify that the expected text and HTML are copied to the clipboard
      // You can use appropriate assertions based on your clipboard implementation
      // For example:
    });
    test('paragraph_copy_handler_test', () async {
      // Arrange
      final editorState =
          EditorState(document: Document.fromJson(paragraphdata));
      // Set up a non-collapsed selection
      final firstSelectable = editorState.document.root.children
          .firstWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      final lastSelectable = editorState.document.root.children
          .lastWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      if (firstSelectable == null || lastSelectable == null) {
        return;
      }
      editorState.updateSelectionWithReason(
        Selection(start: firstSelectable.start(), end: lastSelectable.end()),
      );

      // Act
      _handleCopy(editorState);

      // Assert
      // Verify that the expected text and HTML are copied to the clipboard
      // You can use appropriate assertions based on your clipboard implementation
      // For example:
    });

    test(
        'copy handler should not copy text and HTML when selection is collapsed',
        () async {
      // Arrange
      final editorState = EditorState.blank();
      // Set up a collapsed selection
      final firstSelectable = editorState.document.root.children
          .firstWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      final lastSelectable = editorState.document.root.children
          .lastWhereOrNull(
            (element) => element.selectable != null,
          )
          ?.selectable;
      if (firstSelectable == null || lastSelectable == null) {
        return;
      }
      editorState.updateSelectionWithReason(
        Selection(start: firstSelectable.start(), end: lastSelectable.end()),
      );

      // Act
      copyEventHandler(editorState, null);
      final copiedText = await AppFlowyClipboard.getData();

      // Assert
      // Verify that no text or HTML is copied to the clipboard
      // You can use appropriate assertions based on your clipboard implementation
      // For example:
      expect(copiedText.text, null);
      expect(copiedText.html, null);
    });
  });

  // Add more test cases as needed to cover different scenarios and edge cases
}

Future<void> _handleCopy(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return;
  }
  if (selection.start.path.equals(selection.end.path)) {
    final nodeAtPath = editorState.document.nodeAtPath(selection.end.path)!;

    final textNode = nodeAtPath;
    final htmlString = nodesToHTML([textNode]);
    String textString = "";
    final Delta? delta = textNode.delta;
    final children = textNode.children;
    final plainText = delta != null ? delta.toPlainText() : "";
    if (children == null) {
      textString = plainText;
    } else {
      final String chilrenString = children.fold('', (previousValue, node) {
        final delta = node.delta;
        if (delta != null) {
          return previousValue + '\n' + delta.toPlainText();
        }

        return previousValue;
      });
      textString = "$plainText $chilrenString";
    }
    Log.keyboard.debug('copy html: $htmlString');
    AppFlowyClipboard.setData(
      text: textString,
      html: htmlString,
    );
    final copiedText = await AppFlowyClipboard.getData();
    expect(copiedText.text, paragraphText);
    expect(copiedText.html, paragraphhtml);

    return;
  }

  final beginNode = editorState.document.nodeAtPath(selection.start.path)!;
  final endNode = editorState.document.nodeAtPath(selection.end.path)!;

  final nodes = NodeIterator(
    document: editorState.document,
    startNode: beginNode,
    endNode: endNode,
  ).toList();

  final html = nodesToHTML(nodes);
  var text = '';
  for (final node in nodes) {
    String textString = "";
    final Delta? delta = node.delta;
    final children = node.children;
    final plainText = delta != null ? delta.toPlainText() : "";
    if (children == null) {
      textString = plainText;
    } else {
      final String childrenString =
          children.fold('', (previousValue, stringnode) {
        final delta = node.delta;
        if (delta != null) {
          return previousValue + '\n' + delta.toPlainText();
        }

        return previousValue;
      });
      textString = "$plainText $childrenString";
    }
    text = text + textString + '\n';
  }
  Log.keyboard.debug('copy html: $html');
  AppFlowyClipboard.setData(
    text: text,
    html: html,
  );
  final copiedText = await AppFlowyClipboard.getData();
  expect(copiedText.text, plainText);
  expect(copiedText.html, rawHTML);
}

const paragraphText =
    '''AppFlowy Editor is a highly customizable   rich-text editor ''';
const plainText = '''AppFlowyEditor 
👋 Welcome to   AppFlowy Editor 
AppFlowy Editor is a highly customizable   rich-text editor 
   Here is an example your you can give a try 
   Span element 
   Span element two 
   Span element three 
   This is an anchor tag! 
Features! 
[x] Customizable 
[x] Test-covered 
[ ] more to come! 
First item 
Second item 
List element 
This is a quote! 
 Code block 
   Italic one 
   Italic two 
   Bold tag 
You can also use AppFlowy Editor as a component to build your own app.  
Awesome features 
If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders! 
 
 
''';

const paragraphdata = {
  "document": {
    "type": "page",
    "children": [
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': 'AppFlowy Editor is a '},
            {
              'insert': 'highly customizable',
              'attributes': {'bold': true}
            },
            {'insert': '   '},
            {
              'insert': 'rich-text editor',
              'attributes': {'italic': true}
            }
          ]
        }
      }
    ]
  }
};
const data = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'heading',
        'data': {
          'level': 1,
          'delta': [
            {'insert': 'AppFlowyEditor'}
          ]
        }
      },
      {
        'type': 'heading',
        'data': {
          'level': 2,
          'delta': [
            {'insert': '👋 '},
            {
              'insert': 'Welcome to',
              'attributes': {'bold': true}
            },
            {'insert': '   '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {'bold': true, 'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': 'AppFlowy Editor is a '},
            {
              'insert': 'highly customizable',
              'attributes': {'bold': true}
            },
            {'insert': '   '},
            {
              'insert': 'rich-text editor',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Here',
              'attributes': {'underline': true}
            },
            {'insert': ' is an example '},
            {
              'insert': 'your',
              'attributes': {'strikethrough': true}
            },
            {'insert': ' you can give a try'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element',
              'attributes': {'bold': true, 'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element two',
              'attributes': {'underline': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element three',
              'attributes': {'bold': true, 'strikethrough': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'This is an anchor tag!',
              'attributes': {'href': 'https://appflowy.io'}
            }
          ]
        }
      },
      {
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Features!'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Customizable'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Test-covered'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[ ] more to come!'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'First item'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Second item'}
          ]
        }
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'List element'}
          ]
        }
      },
      {
        'type': 'quote',
        'data': {
          'delta': [
            {'insert': 'This is a quote!'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert': ' Code block',
              'attributes': {'code': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic one',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic two',
              'attributes': {'italic': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Bold tag',
              'attributes': {'bold': true}
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': 'You can also use '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {'bold': true, 'italic': true}
            },
            {'insert': ' as a component to build your own app. '}
          ]
        }
      },
      {
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Awesome features'}
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert':
                  'If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!'
            }
          ]
        }
      },
      {
        'type': 'paragraph',
        'data': {'delta': []}
      },
      {
        'type': 'paragraph',
        'data': {'delta': []}
      }
    ]
  }
};
const paragraphhtml =
    "<p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p>";
const rawHTML =
    '''<h1>AppFlowyEditor</h1><h2>👋 <strong>Welcome to</strong>   <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span></h2><p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p><p>   <u>Here</u> is an example <del>your</del> you can give a try</p><p>   <span style="font-weight: bold; font-style: italic">Span element</span></p><p>   <u>Span element two</u></p><p>   <span style="font-weight: bold; text-decoration: line-through">Span element three</span></p><p>   <a href="https://appflowy.io">This is an anchor tag!</a></p><h3>Features!</h3><ul><li>[x] Customizable</li><li>[x] Test-covered</li><li>[ ] more to come!</li><li>First item</li><li>Second item</li><li>List element</li></ul><blockquote>This is a quote!</blockquote><p><code> Code block</code></p><p>   <i>Italic one</i></p><p>   <i>Italic two</i></p><p>   <strong>Bold tag</strong></p><p>You can also use <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span> as a component to build your own app. </p><h3>Awesome features</h3><p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p><p></p><p></p>''';
