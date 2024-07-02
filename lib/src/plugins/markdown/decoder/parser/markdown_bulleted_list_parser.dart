import 'package:appflowy_editor/appflowy_editor.dart';

class MarkdownBulletedListParser extends CustomMarkdownNodeParser {
  const MarkdownBulletedListParser();

  @override
  Node? transform(DeltaMarkdownDecoder decoder, String input) {
    final match = RegExp(r'^\s*-\s+(.*)').firstMatch(input);
    if (match == null) {
      return null;
    }

    final text = match.group(1)!;

    return bulletedListNode(
      delta: decoder.convert(text),
    );
  }
}
