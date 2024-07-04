import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownOrderedListParserV2 extends CustomMarkdownParser {
  const MarkdownOrderedListParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'ol') {
      return [];
    }

    final startNumber = element.attributes['start'];

    // flatten the list
    return parseElementChildren(
      element.children,
      parsers,
      listType: MarkdownListType.ordered,
      startNumber: startNumber != null ? int.tryParse(startNumber) : null,
    );
  }
}
