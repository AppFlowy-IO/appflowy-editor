import 'package:appflowy_editor/appflowy_editor.dart';

class QuoteNodeParser extends NodeParser {
  const QuoteNodeParser();

  @override
  String get id => QuoteBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final children = encoder?.convertNodes(node.children, withIndent: true);
    String markdown = '> ${DeltaMarkdownEncoder().convert(delta)}\n';
    if (children != null && children.isNotEmpty) {
      markdown += children;
    }
    return markdown;
  }
}
