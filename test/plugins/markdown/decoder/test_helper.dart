import 'package:appflowy_editor/appflowy_editor.dart';

extension CustomMarkdownNodeParserExtension on CustomMarkdownNodeParser {
  Node? parseMarkdown(String input) {
    final decoder = DeltaMarkdownDecoder();
    return transform(decoder, input);
  }
}
