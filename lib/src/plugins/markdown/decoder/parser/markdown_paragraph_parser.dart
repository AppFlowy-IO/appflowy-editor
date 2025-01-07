import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParagraphParserV2 extends CustomMarkdownParser {
  const MarkdownParagraphParserV2();

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

    if (element.tag != 'p') {
      return [];
    }

    // exclude the img tag
    final ec = element.children;
    if (ec != null && ec.length == 1 && ec.first is md.Element) {
      final e = ec.first as md.Element;
      if (e.tag == 'img') {
        return [];
      }
    }

    if (ec == null || ec.isEmpty) {
      // return empty paragraph node if there is no children
      return [
        paragraphNode(),
      ];
    }

    // Split the paragraph node by <br> tag
    final splitContent = _splitByBrTag(ec);

    // Transform each split content into a paragraph node
    return splitContent.map((content) {
      final deltaDecoder = DeltaMarkdownDecoder();
      final delta = deltaDecoder.convertNodes(content);
      return paragraphNode(delta: delta);
    }).toList();

    // return result;
  }
}

// split the <p> children by <br> tag, mostly it's used for handling the soft line break
// for example:
// ```html
// <p>
// Hello<br>World
// </p>
// ```
// will be split into:
// ```document
// Hello
//
// World
// ```
List<List<md.Node>> _splitByBrTag(List<md.Node> nodes) {
  return nodes
      .fold<List<List<md.Node>>>(
        [[]],
        (acc, node) {
          if (node is md.Element && node.tag == 'br') {
            acc.add([]);
          } else {
            acc.last.add(node);
          }
          return acc;
        },
      )
      .where((group) => group.isNotEmpty)
      .toList();
}
