import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/markdown_todo_list_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_todo_list_parser.dart', () {
    test('- [ ]', () {
      const markdown = '- [ ] Task 1\n- [ ] Task 2\n- [ ] Task 3';

      const parser = MarkdownTodoListParser();
      final lines = markdown.split('\n');
      for (var i = 0; i < 3; i++) {
        final decoder = DeltaMarkdownDecoder();
        final result = parser.transform(decoder, lines[i]);
        final checked = result!.attributes[TodoListBlockKeys.checked] as bool;
        expect(result.delta!.toPlainText(), 'Task ${i + 1}');
        expect(checked, false);
      }
    });

    test('- [x]', () {
      const markdown = '- [x] Task 1\n- [x] Task 2\n- [x] Task 3';

      const parser = MarkdownTodoListParser();
      final lines = markdown.split('\n');
      for (var i = 0; i < 3; i++) {
        final decoder = DeltaMarkdownDecoder();
        final result = parser.transform(decoder, lines[i]);
        final checked = result!.attributes[TodoListBlockKeys.checked] as bool;
        expect(result.delta!.toPlainText(), 'Task ${i + 1}');
        expect(checked, true);
      }
    });
  });
}
