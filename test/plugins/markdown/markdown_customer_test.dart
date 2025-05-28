import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    test('customer issue - unordered list with links', () {
      const markdown = '''
- [The Straits Times](https://www.straitstimes.com/)
- [Channel News Asia](https://www.channelnewsasia.com/)
- [Today Online](https://www.todayonline.com/)
''';
      final result = markdownToDocument(markdown);
      expect(
        result.nodeAtPath([0])!.toJson(),
        {
          'type': 'bulleted_list',
          'data': {
            'delta': [
              {
                'insert': 'The Straits Times',
                'attributes': {'href': 'https://www.straitstimes.com/'},
              },
            ],
          },
        },
      );
      expect(
        result.nodeAtPath([1])!.toJson(),
        {
          'type': 'bulleted_list',
          'data': {
            'delta': [
              {
                'insert': 'Channel News Asia',
                'attributes': {'href': 'https://www.channelnewsasia.com/'},
              },
            ],
          },
        },
      );
      expect(
        result.nodeAtPath([2])!.toJson(),
        {
          'type': 'bulleted_list',
          'data': {
            'delta': [
              {
                'insert': 'Today Online',
                'attributes': {'href': 'https://www.todayonline.com/'},
              },
            ],
          },
        },
      );
    });

    test('customer issue - ordered list with numbers', () {
      const markdown = '''
1. **Ensure Dependencies**

Make sure you have the necessary packages in your `pubspec.yaml`. For example, if `FlowyText` and `AFThemeExtension` are from packages, list them under dependencies.

2. **Import Statements**

Add the necessary import statements at the top of your Dart file.

3. **Class Definition**

Here is the complete Dart file with the above steps:
''';
      final result = markdownToDocument(markdown);
      expect(
        result.nodeAtPath([0])!.toJson(),
        {
          'type': 'numbered_list',
          'data': {
            'delta': [
              {
                'insert': 'Ensure Dependencies',
                'attributes': {'bold': true},
              },
            ],
          },
        },
      );
      expect(
        result.nodeAtPath([2])!.toJson(),
        {
          'type': 'numbered_list',
          'data': {
            'number': 2,
            'delta': [
              {
                'insert': 'Import Statements',
                'attributes': {'bold': true},
              },
            ],
          },
        },
      );
      expect(
        result.nodeAtPath([4])!.toJson(),
        {
          'type': 'numbered_list',
          'data': {
            'number': 3,
            'delta': [
              {
                'insert': 'Class Definition',
                'attributes': {'bold': true},
              },
            ],
          },
        },
      );
    });
  });
}
