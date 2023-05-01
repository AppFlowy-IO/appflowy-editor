import 'package:appflowy_editor/appflowy_editor.dart';

class QuoteNodeParser extends NodeParser {
  const QuoteNodeParser();

  @override
  String get id => 'quote';

  @override
  String transform(Node node) {
    assert(node.type == 'quote');

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final result = '> $markdown';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
