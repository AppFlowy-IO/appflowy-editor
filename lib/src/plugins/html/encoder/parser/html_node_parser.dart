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
    final nodeList = nodes.toList();
    var i = 0;

    while (i < nodeList.length) {
      final current = nodeList[i];
      // Process children nodes wrapping sequences of lists (bulleted or numbered)
      // in the respective container tags <ul> or <ol>, ensuring proper indentation and HTML structure.
      if (current.type == BulletedListBlockKeys.type) {
        final ul = dom.Element.tag('ul');
        while (i < nodeList.length &&
            nodeList[i].type == BulletedListBlockKeys.type) {
          final node = nodeList[i];
          final parser =
              encodeParsers.firstWhereOrNull((p) => p.id == node.type);
          if (parser != null) {
            final doms = parser.transformNodeToDomNodes(
              node,
              encodeParsers: encodeParsers,
            );
            for (final d in doms) {
              ul.append(d);
            }
          }
          i++;
        }
        result.add(ul);
      } else if (current.type == NumberedListBlockKeys.type) {
        final ol = dom.Element.tag('ol');
        final number = current.attributes[NumberedListBlockKeys.number];
        if (number != null && number != 1) {
          ol.attributes['start'] = '$number';
        }
        while (i < nodeList.length &&
            nodeList[i].type == NumberedListBlockKeys.type) {
          final node = nodeList[i];
          final parser =
              encodeParsers.firstWhereOrNull((p) => p.id == node.type);
          if (parser != null) {
            final doms = parser.transformNodeToDomNodes(
              node,
              encodeParsers: encodeParsers,
            );
            for (final d in doms) {
              ol.append(d);
            }
          }
          i++;
        }
        result.add(ol);
      } else {
        // process other node types
        final parser = encodeParsers.firstWhereOrNull(
          (p) => p.id == current.type,
        );
        if (parser != null) {
          result.addAll(
            parser.transformNodeToDomNodes(
              current,
              encodeParsers: encodeParsers,
            ),
          );
        }
        i++;
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
