import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLBulletedListNodeParser extends HTMLNodeParser {
  const HTMLBulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == BulletedListBlockKeys.type);

    final html = toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );

    const start = '<ul>';
    const end = '</ul>';
    if (node.previous?.type != BulletedListBlockKeys.type &&
        node.next?.type != BulletedListBlockKeys.type) {
      return '$start$html$end';
    } else if (node.previous?.type != BulletedListBlockKeys.type) {
      return '$start$html';
    } else if (node.next?.type != BulletedListBlockKeys.type) {
      return '$html$end';
    } else {
      return html;
    }
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);
    domNodes.addAll(
      processChildrenNodes(
        node.children,
        encodeParsers: encodeParsers,
      ),
    );
    final element = wrapChildrenNodesWithTagName(
      HTMLTags.list,
      childNodes: domNodes,
    );
    return [element];
  }
}
