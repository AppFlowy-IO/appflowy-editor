import 'package:appflowy_editor/appflowy_editor.dart';

class NumberedListNodeParser extends NodeParser {
  const NumberedListNodeParser();

  @override
  String get id => NumberedListBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final number = node.attributes[NumberedListBlockKeys.number] ?? '1';
    final children = encoder?.convertNodes(node.children, withIndent: true);
    String markdown = '$number. ${DeltaMarkdownEncoder().convert(delta)}\n';
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
