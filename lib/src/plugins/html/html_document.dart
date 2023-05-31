library delta_markdown;

import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_decoder.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_encoder.dart';

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
