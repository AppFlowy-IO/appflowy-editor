import 'package:appflowy_editor/appflowy_editor.dart';

class MarkdownTodoListParser extends CustomMarkdownNodeParser {
  const MarkdownTodoListParser();

  @override
  Node? transform(DeltaMarkdownDecoder decoder, String input) {
    final match = RegExp(r'^\s*-\s+\[(x| )\]\s+(.*)').firstMatch(input);
    if (match == null) {
      return null;
    }

    final checked = match.group(1) == 'x';
    final text = match.group(2)!;

    return todoListNode(
      checked: checked,
      delta: decoder.convert(text),
    );
  }
}
