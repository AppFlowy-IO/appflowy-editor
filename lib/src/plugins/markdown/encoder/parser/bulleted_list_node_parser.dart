import 'package:appflowy_editor/appflowy_editor.dart';

class BulletedListNodeParser extends NodeParser {
  const BulletedListNodeParser();

  @override
  String get id => 'bulleted_list';

  @override
  String transform(Node node) {
    assert(node.type == 'bulleted_list');

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final result = '* $markdown';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
