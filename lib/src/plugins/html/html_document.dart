library;

import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/plugins/html/encoder/parser/divider_node_parser.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_decoder.dart';
import 'package:appflowy_editor/src/plugins/html/html_document_encoder.dart';

import 'encoder/parser/html_parser.dart';

export 'html_document_decoder.dart' show ElementParser;

/// Converts a html to [Document].
Document htmlToDocument(
  String html, {
  Map<String, ElementParser> customDecoders = const {},
}) {
  return AppFlowyEditorHTMLCodec(
    customDecoders: customDecoders,
  ).decode(html);
}

/// Converts a [Document] to html.
String documentToHTML(
  Document document, {
  List<HTMLNodeParser> customParsers = const [],
}) {
  return AppFlowyEditorHTMLCodec(
    encodeParsers: [
      ...customParsers,
      const HTMLTextNodeParser(),
      const HTMLBulletedListNodeParser(),
      const HTMLNumberedListNodeParser(),
      const HTMLTodoListNodeParser(),
      const HTMLQuoteNodeParser(),
      const HTMLHeadingNodeParser(),
      const HTMLImageNodeParser(),
      const HtmlTableNodeParser(),
      const HTMLDividerNodeParser(),
    ],
  ).encode(document);
}

class AppFlowyEditorHTMLCodec extends Codec<Document, String> {
  const AppFlowyEditorHTMLCodec({
    this.encodeParsers = const [],
    this.customDecoders = const {},
  });

  final List<HTMLNodeParser> encodeParsers;
  final Map<String, ElementParser> customDecoders;

  @override
  Converter<String, Document> get decoder => DocumentHTMLDecoder(
        customDecoders: customDecoders,
      );

  @override
  Converter<Document, String> get encoder => DocumentHTMLEncoder(
        encodeParsers: encodeParsers,
      );
}
