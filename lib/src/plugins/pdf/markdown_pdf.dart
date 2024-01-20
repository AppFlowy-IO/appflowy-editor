import 'dart:io';
import 'dart:convert';
import 'package:appflowy_editor/src/core/document/text_delta.dart';
import 'package:appflowy_editor/src/editor/editor.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:markdown/markdown.dart' as md;
import 'package:appflowy_editor/appflowy_editor.dart';

String convert(Delta input) {
  final buffer = StringBuffer();
  final iterator = input.iterator;
  while (iterator.moveNext()) {
    final op = iterator.current;
    if (op is TextInsert) {
      final attributes = op.attributes;
      if (attributes != null) {
        buffer.write(_prefixSyntax(attributes));
        buffer.write(op.text);
        buffer.write(_suffixSyntax(attributes));
      } else {
        buffer.write(op.text);
      }
    }
  }
  return buffer.toString();
}

String _prefixSyntax(Attributes attributes) {
  var syntax = '';

  if (attributes[BuiltInAttributeKey.bold] == true &&
      attributes[BuiltInAttributeKey.italic] == true) {
    syntax += '***';
  } else if (attributes[BuiltInAttributeKey.bold] == true) {
    syntax += '**';
  } else if (attributes[BuiltInAttributeKey.italic] == true) {
    syntax += '_';
  }

  if (attributes[BuiltInAttributeKey.strikethrough] == true) {
    syntax += '~~';
  }
  if (attributes[BuiltInAttributeKey.underline] == true) {
    syntax += '<u>';
  }
  if (attributes[BuiltInAttributeKey.code] == true) {
    syntax += '`';
  }

  if (attributes[BuiltInAttributeKey.href] != null) {
    syntax += '[';
  }

  return syntax;
}

String _suffixSyntax(Attributes attributes) {
  var syntax = '';

  if (attributes[BuiltInAttributeKey.href] != null) {
    syntax += '](${attributes[BuiltInAttributeKey.href]})';
  }

  if (attributes[BuiltInAttributeKey.code] == true) {
    syntax += '`';
  }

  if (attributes[BuiltInAttributeKey.underline] == true) {
    syntax += '</u>';
  }

  if (attributes[BuiltInAttributeKey.strikethrough] == true) {
    syntax += '~~';
  }

  if (attributes[BuiltInAttributeKey.bold] == true &&
      attributes[BuiltInAttributeKey.italic] == true) {
    syntax += '***';
  } else if (attributes[BuiltInAttributeKey.bold] == true) {
    syntax += '**';
  } else if (attributes[BuiltInAttributeKey.italic] == true) {
    syntax += '_';
  }

  return syntax;
}

pw.Document generatePdfFromMarkdown(String markdownContent, EditorState state) {
  final pdf = pw.Document();
  final List<String> lines = md.markdownToHtml(markdownContent).split('\n');
/*
  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          children: lines.map((line) => pw.Text(line)).toList(),
        );
      },
    ),
  );
    */
  final data = state.document.root.children;

  String todoBlockParser(Node node) {
    final children =
        DocumentMarkdownEncoder().convertNodes(node.children, withIndent: true);
    String mark = convert(node.delta!);
    if (children != null && children.isNotEmpty) {
      mark += children;
    }
    return mark;
  }

  String bulletBlockParser(Node node) {
    final children =
        DocumentMarkdownEncoder().convertNodes(node.children, withIndent: true);
    String mark = convert(node.delta!);
    if (children != null && children.isNotEmpty) {
      mark += children;
    }
    return mark;
  }

  print(data.map((item) {
    switch (item.type) {
      case BulletedListBlockKeys.type:
        print(bulletBlockParser(item));
      case TableBlockKeys.type:
        print('Unimplemented table');
      default:
        print(convert(item.delta!));
    }
  }));

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          children: data
              .map(
                (el) => switch (el.type) {
                  HeadingBlockKeys.type => pw.Header(
                      level: el.attributes['level'],
                      title: convert(el.delta!),
                      //NOTE: Needs PDFGoogle Font package
                      //textStyle: pw.TextStyle(fontFallback: [emoji])
                    ),

                  //NOTE: Children nodes are the problem

                  /*
NOTE: For whatever reason it just 
doesnt like it me trying to put a Column within a list
*/
                  /*
                    NOTE: Handle children nodes
                        */
                  BulletedListBlockKeys.type => el.children.isNotEmpty
                      ? pw.Column(children: [pw.Text('Hello')])
                      : pw.Bullet(text: convert(el.delta!)),
                  TodoListBlockKeys.type => el.children.isNotEmpty
                      ? pw.Column(
                          children: [pw.Checkbox(value: false, name: 'Sample')],
                        )
                      //BUG: Seems like it doesnt like rows within a .toList() method
                      : pw.Row(
                          children: [
                            pw.Checkbox(
                              name: convert(el.delta!),
                              value: el.attributes[TodoListBlockKeys.checked],
                            ),
                            pw.Text('CheckMar'),
                          ],
                        ),

                  //NOTE: Table needs handling.
                  TableBlockKeys.type => pw.SizedBox.shrink(),
                  ParagraphBlockKeys.type =>
                    pw.Paragraph(text: convert(el.delta!)),
                  _ => pw.Text(convert(el.delta!)),
                },
              )
              .toList(),
        );
      },
    ),
  );
  return pdf;
}
