import 'dart:io';
import 'dart:convert';
import 'package:appflowy_editor/src/core/document/text_delta.dart';
import 'package:appflowy_editor/src/editor/editor.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:markdown/markdown.dart' as md;

Document generatePdfFromMarkdown(String markdownContent, EditorState state) {
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
  final buffer = StringBuffer();
  print(data.map((item) {
    if (item.type == ParagraphBlockKeys.type) {
      final d = item.delta;
      final mover = d!.iterator;
      while (mover.moveNext()) {
        final curr = mover.current;
        if (curr is TextInsert) {
          buffer.write(curr.text);
        }
      }
    }
  }));
  print(buffer);

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          children: data
              .map((el) => switch (el.type) {
                    ParagraphBlockKeys.type => pw.Text(el.delta.toString()),
                    _ => pw.Text('')
                  })
              .toList(),
        );
      },
    ),
  );
  return pdf;
}
