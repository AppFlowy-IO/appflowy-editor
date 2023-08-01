import 'package:appflowy_editor/appflowy_editor.dart';

class CodeBlockNodeParser extends NodeParser {
  const CodeBlockNodeParser();

  @override
  String get id => 'code';

  @override
  String transform(Node node) {
    assert(node.type == 'code');

    final delta = node.delta;
    final language = node.attributes['language'] ?? '';
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final result = '```$language\n$markdown\n```';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
