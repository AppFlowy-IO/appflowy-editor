library delta_markdown;

import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_decoder.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_encoder.dart';

import 'encoder/parser/htmlparser.dart';

/// Converts a html to [Document].
Document htmlToDocument(String html) {
  return const AppFlowyEditorHTMLCodec().decode(html);
}

/// Converts a [Document] to html.
String documentToHTML(
  Document document, {
  List<HtmlNodeParser> customParsers = const [],
}) {
  return AppFlowyEditorHTMLCodec(
    encodeParsers: [
      ...customParsers,
      const HtmlTextNodeParser(),
      const HtmlBulletedListNodeParser(),
      const HtmlNumberedListNodeParser(),
      const HtmlTodoListNodeParser(),
      const HtmlQuoteNodeParser(),
      const HtmlHeadingNodeParser(),
      const HtmlImageNodeParser(),
    ],
  ).encode(document);
}

class AppFlowyEditorHTMLCodec extends Codec<Document, String> {
  const AppFlowyEditorHTMLCodec({
    this.encodeParsers = const [],
  });

  final List<HtmlNodeParser> encodeParsers;

  @override
  Converter<String, Document> get decoder => DocumentHTMLDecoder();

  @override
  Converter<Document, String> get encoder =>
      DocumentHTMLEncoder(encodeParsers: encodeParsers);
}
