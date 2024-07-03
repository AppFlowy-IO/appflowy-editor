import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

abstract class CustomMarkdownNodeParser {
  const CustomMarkdownNodeParser();

  Node? transform(DeltaMarkdownDecoder decoder, String input);
}

abstract class CustomMarkdownElementParser {
  const CustomMarkdownElementParser();

  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  );
}
