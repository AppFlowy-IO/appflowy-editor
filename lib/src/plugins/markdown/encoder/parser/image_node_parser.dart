import 'package:appflowy_editor/appflowy_editor.dart';

class ImageNodeParser extends NodeParser {
  const ImageNodeParser();

  @override
  String get id => 'image';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    return '![](${node.attributes['image_src']})';
  }
}
