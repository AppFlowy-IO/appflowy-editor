import 'package:appflowy_editor/appflowy_editor.dart';

abstract class CustomMarkdownNodeParser {
  const CustomMarkdownNodeParser();

  Node? transform(DeltaMarkdownDecoder decoder, String input);
}
