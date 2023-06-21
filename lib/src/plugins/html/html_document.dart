library html_to_document;

import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

/// Converts a html to [Document].
Document htmlToDocument(String html) {
  return const AppFlowyEditorHTMLCodec().decode(html);
}

/// Converts a [Document] to html.
String documentToHTML(Document document) {
  return const AppFlowyEditorHTMLCodec().encode(document);
}

class AppFlowyEditorHTMLCodec extends Codec<Document, String> {
  const AppFlowyEditorHTMLCodec();

  @override
  Converter<String, Document> get decoder => DocumentHTMLDecoder();

  @override
  Converter<Document, String> get encoder => DocumentHTMLEncoder();
}
