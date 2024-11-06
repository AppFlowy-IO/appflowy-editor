import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownTodoListParserV2 extends CustomMarkdownParser {
  const MarkdownTodoListParserV2();

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

    if (element.tag != 'li' ||
        element.attributes['class'] != 'task-list-item') {
      return [];
    }

    final ec = element.children;
    if (ec == null || ec.isEmpty) {
      return [];
    }

    // for the task list item, the first two children are the input and the label
    // the rest are its children
    final checked = (ec[0] as md.Element).attributes['checked'] == 'true';
    md.Element? last;
    // if the last child is not a list or paragraph, ignore it
    if (ec.last is md.Element) {
      final lastElement = ec.last as md.Element;
      if (lastElement.tag == 'ul' || lastElement.tag == 'ol') {
        last = lastElement;
      }
    }

    final deltaDecoder = DeltaMarkdownDecoder();
    return [
      todoListNode(
        checked: checked,
        delta: deltaDecoder.convertNodes(
          element.children?.sublist(
            1,
            ec.length - (last != null ? 1 : 0),
          ),
        ),
        children: last == null
            ? null
            : parseElementChildren(
                [last],
                parsers,
                listType: MarkdownListType.unknown,
              ),
      ),
    ];
  }
}
