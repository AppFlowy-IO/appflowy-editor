import 'package:appflowy_editor/appflowy_editor.dart';

class TodoListNodeParser extends NodeParser {
  const TodoListNodeParser();

  @override
  String get id => 'todo_list';

  @override
  String transform(Node node) {
    assert(node.type == 'todo_list');

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final attributes = node.attributes;
    final checked = attributes[TodoListBlockKeys.checked] == true;
    final result = checked ? '- [x] $markdown' : '- [ ] $markdown';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
