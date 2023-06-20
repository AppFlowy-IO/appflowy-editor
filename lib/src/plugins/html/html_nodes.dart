library html_to_nodes;

import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

List<Node> htmlToNodes(String html) {
  return const AppFlowyEditorHTMLNodeCodec().decode(html);
}

/// Converts a [Document] to html.
String nodesToHTML(List<Node> nodes) {
  return const AppFlowyEditorHTMLNodeCodec().encode(nodes);
}

class AppFlowyEditorHTMLNodeCodec extends Codec<List<Node>, String> {
  const AppFlowyEditorHTMLNodeCodec();

  @override
  Converter<String, List<Node>> get decoder => NodeHTMLDecoder();

  @override
  Converter<List<Node>, String> get encoder => NodeHTMLEncoder();
}
