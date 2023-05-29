import 'package:appflowy_editor/appflowy_editor.dart';

class CodeBlockNodeParser extends NodeParser {
  const CodeBlockNodeParser();

  @override
  String get id => 'code_block';

  @override
  String transform(Node node) {
    assert(node.type == 'code_block');

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final result = '```\n$markdown\n```';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
