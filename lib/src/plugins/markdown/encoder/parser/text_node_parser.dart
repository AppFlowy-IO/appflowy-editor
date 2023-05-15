import 'package:appflowy_editor/appflowy_editor.dart';

class TextNodeParser extends NodeParser {
  const TextNodeParser();

  @override
  String get id => 'paragraph';

  @override
  String transform(Node node) {
    final delta = node.delta;
    if (delta == null) {
      assert(false, 'Delta is null');
      return '';
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final suffix = node.next == null ? '' : '\n';
    return '$markdown$suffix';
  }
}
