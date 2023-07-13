import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

abstract class HtmlNodeParser {
  const HtmlNodeParser();

  String get id;
  String transform(Node node);
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

String toHTMLString(List<dom.Node> nodes) {
  final elements = nodes;
  final copyString = elements.fold<String>(
    '',
    (previousValue, element) => previousValue + stringify(element),
  );
  return copyString.replaceAll("\n", "");
}
