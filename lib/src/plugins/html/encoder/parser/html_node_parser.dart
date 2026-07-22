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

  /// Like [processChildrenNodes] but preserves list NESTING.
  ///
  /// A list item's child list nodes (`transformNodeToDomNodes` returns a bare
  /// `<li>`) must be wrapped in their own `<ol>`/`<ul>` — otherwise the emitted
  /// HTML is `<li>parent<li>child</li></li>`, which every HTML parser "fixes"
  /// by flattening the inner `<li>` into a sibling, collapsing the nesting.
  /// Consecutive same-type list children share one wrapper; non-list children
  /// pass through unchanged.
  List<dom.Node> processChildrenNodesPreservingListNesting(
    Iterable<Node> nodes, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final result = <dom.Node>[];
    dom.Element? openList;
    String? openListTag;

    void flush() {
      if (openList != null) {
        result.add(openList!);
        openList = null;
        openListTag = null;
      }
    }

    for (final node in nodes) {
      final parser = encodeParsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser == null) {
        continue;
      }
      final childDom =
          parser.transformNodeToDomNodes(node, encodeParsers: encodeParsers);
      final String? listTag = node.type == NumberedListBlockKeys.type
          ? HTMLTags.orderedList
          : node.type == BulletedListBlockKeys.type
              ? HTMLTags.unorderedList
              : null;
      if (listTag == null) {
        flush();
        result.addAll(childDom);
        continue;
      }
      if (openListTag != listTag) {
        flush();
        openList = dom.Element.tag(listTag);
        openListTag = listTag;
      }
      for (final n in childDom) {
        openList!.append(n);
      }
    }
    flush();

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
