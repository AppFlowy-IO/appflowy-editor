library delta_markdown;

import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder_v2.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/parser.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/parser.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/document_markdown_encoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/parser.dart';
import 'package:markdown/markdown.dart' as md;

/// Converts a markdown to [Document].
///
/// [customParsers] is a list of custom parsers that will be used to parse the markdown.
Document markdownToDocument(
  String markdown, {
  List<CustomMarkdownElementParser> markdownElementParsers = const [],
  List<CustomMarkdownNodeParser> customParsers = const [],
  List<md.InlineSyntax> customInlineSyntaxes = const [],
}) {
  return AppFlowyEditorMarkdownCodec(
    customInlineSyntaxes: customInlineSyntaxes,
    customMarkdownElementParsers: [
      ...markdownElementParsers,
      const MarkdownParagraphParserV2(),
      const MarkdownHeadingParserV2(),
      const MarkdownTodoListParserV2(),
      const MarkdownUnorderedListParserV2(),
      const MarkdownOrderedListParserV2(),
      const MarkdownUnorderedListItemParserV2(),
      const MarkdownOrderedListItemParserV2(),
      const MarkdownBlockQuoteParserV2(),
      const MarkdownTableListParserV2(),
      const MarkdownDividerParserV2(),
      const MarkdownImageParserV2(),
    ],
    customParsers: [
      ...customParsers,

      // built-in parsers
      const MarkdownHeadingParser(),
      const MarkdownTodoListParser(),
      const MarkdownQuoteListParser(),
    ],
  ).decode(markdown);
}

/// Converts a [Document] to markdown.
///
/// [customParsers] is a list of custom parsers that will be used to parse the markdown.
String documentToMarkdown(
  Document document, {
  List<NodeParser> customParsers = const [],
}) {
  return AppFlowyEditorMarkdownCodec(
    encodeParsers: [
      ...customParsers,
      const TextNodeParser(),
      const BulletedListNodeParser(),
      const NumberedListNodeParser(),
      const TodoListNodeParser(),
      const QuoteNodeParser(),
      const CodeBlockNodeParser(),
      const HeadingNodeParser(),
      const ImageNodeParser(),
      const TableNodeParser(),
      const DividerNodeParser(),
    ],
  ).encode(document);
}

class AppFlowyEditorMarkdownCodec extends Codec<Document, String> {
  const AppFlowyEditorMarkdownCodec({
    this.customParsers = const [],
    this.customInlineSyntaxes = const [],
    this.customMarkdownElementParsers = const [],
    this.encodeParsers = const [],
  });

  final List<NodeParser> encodeParsers;
  final List<CustomMarkdownNodeParser> customParsers;
  final List<CustomMarkdownElementParser> customMarkdownElementParsers;
  final List<md.InlineSyntax> customInlineSyntaxes;

  // @override
  // Converter<String, Document> get decoder => DocumentMarkdownDecoder(
  //       customNodeParsers: customParsers,
  //       customInlineSyntaxes: customInlineSyntaxes,
  //     );

  @override
  Converter<String, Document> get decoder => DocumentMarkdownDecoderV2(
        markdownElementParsers: customMarkdownElementParsers,
        inlineSyntaxes: customInlineSyntaxes,
      );

  @override
  Converter<Document, String> get encoder => DocumentMarkdownEncoder(
        parsers: encodeParsers,
      );
}
