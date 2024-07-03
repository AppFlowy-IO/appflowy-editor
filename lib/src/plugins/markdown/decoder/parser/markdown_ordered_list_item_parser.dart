import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownOrderedListItemParserV2 extends CustomMarkdownParser {
  const MarkdownOrderedListItemParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'li' ||
        element.attributes.isNotEmpty ||
        listType != MarkdownListType.ordered) {
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
      numberedListNode(
        delta: deltaDecoder.convertNodes(
          deltaNodes,
        ),
        children: parseElementChildren(
          ec.reversed.toList(),
          parsers,
          listType: MarkdownListType.ordered,
        ),
      ),
    ];
  }
}
