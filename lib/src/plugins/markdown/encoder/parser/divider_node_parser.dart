import 'package:appflowy_editor/appflowy_editor.dart';

class DividerNodeParser extends NodeParser {
  const DividerNodeParser();

  @override
  String get id => DividerBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final children = encoder?.convertNodes(node.children);
    String markdown = '---\n';
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
