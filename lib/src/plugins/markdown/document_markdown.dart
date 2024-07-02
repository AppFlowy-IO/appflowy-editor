library delta_markdown;

import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/parser.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/document_markdown_encoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/parser.dart';
import 'package:markdown/markdown.dart' as md;

/// Converts a markdown to [Document].
///
/// [customParsers] is a list of custom parsers that will be used to parse the markdown.
Document markdownToDocument(
  String markdown, {
  List<CustomMarkdownNodeParser> customParsers = const [],
  List<md.InlineSyntax> customInlineSyntaxes = const [],
}) {
  return AppFlowyEditorMarkdownCodec(
    customInlineSyntaxes: customInlineSyntaxes,
    customParsers: [
      ...customParsers,

      // built-in parsers
      const MarkdownHeadingParser(),
      const MarkdownTodoListParser(),
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
    this.encodeParsers = const [],
  });

  final List<NodeParser> encodeParsers;
  final List<CustomMarkdownNodeParser> customParsers;
  final List<md.InlineSyntax> customInlineSyntaxes;

  @override
  Converter<String, Document> get decoder => DocumentMarkdownDecoder(
        customNodeParsers: customParsers,
        customInlineSyntaxes: customInlineSyntaxes,
      );

  @override
  Converter<Document, String> get encoder => DocumentMarkdownEncoder(
        parsers: encodeParsers,
      );
}
