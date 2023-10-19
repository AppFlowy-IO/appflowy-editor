import 'package:appflowy_editor/appflowy_editor.dart';

class BulletedListNodeParser extends NodeParser {
  const BulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final children = encoder?.convertNodes(node.children, withIndent: true);
    String markdown = '* ${DeltaMarkdownEncoder().convert(delta)}\n';
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
