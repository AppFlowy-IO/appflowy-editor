import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder_v2.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_list_parser_v2.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_todo_list_parser_v2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_todo_list_parser.dart', () {
    final parser = DocumentMarkdownDecoderV2(
      markdownElementParsers: [
        const MarkdownUnorderedListParserV2(),
        const MarkdownTodoListParserV2(),
      ],
    );

    test('- [ ]', () {
      const markdown = '''
- [x] Task **1**
    - [ ] Task A
- [ ] Task 2
- [ ] Task 3
''';
      final result = parser.convert(markdown);
      for (var i = 0; i < 3; i++) {
        expect(result.root.children[i].toJson(), {
          'type': 'todo_list',
          'data': {
            'checked': false,
            'delta': [
              {'insert': 'Task ${i + 1}'},
            ],
          },
        });
      }
    });

    // test('- [x]', () {
    //   const markdown = '- [x] Task 1\n- [x] Task 2\n- [x] Task 3';

    //   final lines = markdown.split('\n');
    //   for (var i = 0; i < 3; i++) {
    //     final result = parser.parseMarkdown(lines[i]);
    //     final checked = result!.attributes[TodoListBlockKeys.checked] as bool;
    //     expect(result.delta!.toPlainText(), 'Task ${i + 1}');
    //     expect(checked, true);
    //   }
    // });
  });
}
