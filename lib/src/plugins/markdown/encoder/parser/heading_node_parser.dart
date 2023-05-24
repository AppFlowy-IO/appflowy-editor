import 'package:appflowy_editor/appflowy_editor.dart';

class HeadingNodeParser extends NodeParser {
  const HeadingNodeParser();

  @override
  String get id => 'heading';

  @override
  String transform(Node node) {
    assert(node.type == 'heading');

    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final attributes = node.attributes;
    final level = attributes[HeadingBlockKeys.level] as int? ?? 1;
    final result = '${'#' * level} $markdown';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
