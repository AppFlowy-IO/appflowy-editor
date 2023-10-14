import 'package:appflowy_editor/appflowy_editor.dart';

class HeadingNodeParser extends NodeParser {
  const HeadingNodeParser();

  @override
  String get id => HeadingBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta ?? Delta()
      ..insert('');
    final markdown = DeltaMarkdownEncoder().convert(delta);
    final attributes = node.attributes;
    final level = attributes[HeadingBlockKeys.level] as int? ?? 1;
    final result = '${'#' * level} $markdown';
    final suffix = node.next == null ? '' : '\n';

    return '$result$suffix';
  }
}
