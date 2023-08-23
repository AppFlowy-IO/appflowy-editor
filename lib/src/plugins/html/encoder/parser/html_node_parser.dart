import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

abstract class HTMLNodeParser {
  const HTMLNodeParser();

  /// The id of the node parser.
  ///
  /// Basically, it's the type of the node.
  String get id;

  /// Transform the [node] to html string.
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  });

  /// Convert the [node] to html nodes.
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  });

  dom.Element wrapChildrenNodesWithTagName(
    String tagName, {
    required List<dom.Node> childNodes,
  }) {
    final p = dom.Element.tag(tagName);
    for (final node in childNodes) {
      p.append(node);
    }
    return p;
  }

  // iterate over its children if exist
  List<dom.Node> processChildrenNodes(
    Iterable<Node> nodes, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final result = <dom.Node>[];
    for (final node in nodes) {
      final parser = encodeParsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser != null) {
        result.addAll(
          parser.transformNodeToDomNodes(node, encodeParsers: encodeParsers),
        );
      }
    }
    return result;
  }

  String toHTMLString(List<dom.Node> nodes) =>
      nodes.map((e) => stringify(e)).join().replaceAll('\n', '');
}

String stringify(dom.Node node) {
  if (node is dom.Element) {
    return node.outerHtml;
  }

  if (node is dom.Text) {
    return node.text;
  }

  return '';
}
