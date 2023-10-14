import 'package:appflowy_editor/appflowy_editor.dart';

class TodoListNodeParser extends NodeParser {
  const TodoListNodeParser();

  @override
  String get id => TodoListBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final checked =
        node.attributes[TodoListBlockKeys.checked] == true ? '- [x]' : '- [ ]';
    final children = encoder?.convertNodes(node.children, withIndent: true);
    String markdown = '$checked ${DeltaMarkdownEncoder().convert(delta)}\n';
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
