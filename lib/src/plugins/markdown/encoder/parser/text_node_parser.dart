import 'package:appflowy_editor/appflowy_editor.dart';

class TextNodeParser extends NodeParser {
  const TextNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final children = encoder?.convertNodes(node.children, withIndent: true);
    String markdown = DeltaMarkdownEncoder().convert(delta);
    if (markdown.isEmpty && children == null) {
      return '';
    } else if (node
            .findParent((element) => element.type == TableBlockKeys.type) ==
        null) {
      markdown += '\n';
    }
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
