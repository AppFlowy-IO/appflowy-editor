import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

abstract class HtmlNodeParser {
  const HtmlNodeParser();

  String get id;
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers});
  List<dom.Node> htmlNodes(
    Node node, {
    required List<HtmlNodeParser> encodeParsers,
  });
}

dom.Element insertText(
  String tagName, {
  required List<dom.Node> childNodes,
}) {
  final p = dom.Element.tag(tagName);
  for (final node in childNodes) {
    p.append(node);
  }
  return p;
}

//iterate over its childrens if exist
List<dom.Node> childrenNodes(
  List<Node> nodes, {
  required List<HtmlNodeParser> encodeParsers,
}) {
  final result = <dom.Node>[];
  for (final node in nodes) {
    HtmlNodeParser? parser = encodeParsers.firstWhereOrNull(
      (element) => element.id == node.type,
    );
    if (parser != null) {
      result.addAll(parser.htmlNodes(node, encodeParsers: encodeParsers));
    }
  }
  return result;
}

String toHTMLString(List<dom.Node> nodes) {
  final elements = nodes;
  final copyString = elements.fold<String>(
    '',
    (previousValue, element) => previousValue + stringify(element),
  );
  return copyString.replaceAll("\n", "");
}
