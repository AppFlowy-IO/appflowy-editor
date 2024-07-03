import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_parser_extension.dart';
import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownListItemParserV2 extends CustomMarkdownElementParser {
  const MarkdownListItemParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'li' || element.attributes.isNotEmpty) {
      return [];
    }

    final List<md.Node> ec = [];
    int sliceIndex = -1;
    if (element.children != null) {
      for (final child in element.children!.reversed) {
        if (child is md.Element) {
          ec.add(child);
        } else {
          break;
        }
      }

      sliceIndex = element.children!.length - ec.length;
    }

    final deltaDecoder = DeltaMarkdownDecoder();
    final deltaNodes = sliceIndex == -1
        ? element.children
        : element.children!.slice(0, sliceIndex);

    return [
      bulletedListNode(
        delta: deltaDecoder.convertNodes(
          deltaNodes,
        ),
        children: parseElementChildren(
          ec.reversed.toList(),
          parsers,
        ),
      ),
    ];
  }
}
