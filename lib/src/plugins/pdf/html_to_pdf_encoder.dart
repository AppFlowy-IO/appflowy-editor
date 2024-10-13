import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'extension/color_ext.dart';
import 'package:http/http.dart';
import 'package:markdown/markdown.dart' as md;

/// This class handles conversion from html to pdf
class PdfHTMLEncoder {
  final pw.Font? font;
  final List<pw.Font> fontFallback;

  PdfHTMLEncoder({
    this.font,
    required this.fontFallback,
  });

  Future<pw.Document> convert(String input) async {
    final htmlx = md.markdownToHtml(
      input,
      blockSyntaxes: const [
        md.TableSyntax(),
      ],
      inlineSyntaxes: [
        md.InlineHtmlSyntax(),
        md.ImageSyntax(),
        md.StrikethroughSyntax(),
      ],
    );
    final document = parse(htmlx);
    final body = document.body;
    if (body == null) {
      final blank = pw.Document();
      blank.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(children: [pw.SizedBox.shrink()]);
          },
        ),
      );
      return blank;
    }
    final nodes = await _parseElement(body.nodes);
    final newPdf = pw.Document();
    newPdf.addPage(
      pw.MultiPage(build: (pw.Context context) => nodes.toList()),
    );
    return newPdf;
  }

  Future<List<pw.Widget>> _parseElement(
    Iterable<dom.Node> domNodes, {
    String? type,
    pw.TextAlign? textAlign,
  }) async {
    final textSpan = <pw.TextSpan>[];
    final nodes = <pw.Widget>[];
    for (final domNode in domNodes) {
      if (domNode is dom.Element) {
        final localName = domNode.localName;
        if (localName == HTMLTags.br) {
          textSpan.add(const pw.TextSpan(text: '\n'));
        } else if (HTMLTags.formattingElements.contains(localName)) {
          final attributes = _parserFormattingElementAttributes(domNode);
          nodes.add(
            pw.Paragraph(
              text: domNode.text,
              style: attributes.$2,
            ),
          );
        } else if (HTMLTags.specialElements.contains(localName)) {
          if (textSpan.isNotEmpty) {
            final newTextSpanList = List<pw.TextSpan>.from(textSpan);
            nodes.add(
              pw.SizedBox(
                width: double.infinity,
                child: pw.RichText(
                  textAlign: textAlign,
                  text: pw.TextSpan(
                    children: newTextSpanList,
                    style: pw.TextStyle(font: font, fontFallback: fontFallback),
                  ),
                ),
              ),
            );
            textAlign = null;
            textSpan.clear();
          }
          nodes.addAll(
            await _parseSpecialElements(
              domNode,
              type: type ?? ParagraphBlockKeys.type,
            ),
          );
        }
      } else if (domNode is dom.Text) {
        if (domNode.text.trim().isNotEmpty && textSpan.isNotEmpty) {
          final newTextSpanList = List<pw.TextSpan>.from(textSpan);
          nodes.add(
            pw.SizedBox(
              width: double.infinity,
              child: pw.RichText(
                textAlign: textAlign,
                text: pw.TextSpan(
                  children: newTextSpanList,
                  style: pw.TextStyle(font: font, fontFallback: fontFallback),
                ),
              ),
            ),
          );
          textAlign = null;
          textSpan.clear();
        }
        nodes.add(
          pw.Text(
            domNode.text,
            style: pw.TextStyle(font: font, fontFallback: fontFallback),
          ),
        );
      } else {
        assert(false, 'Unknown node type: $domNode');
      }
    }
    if (textSpan.isNotEmpty) {
      final newTextSpanList = List<pw.TextSpan>.from(textSpan);
      nodes.add(
        pw.SizedBox(
          width: double.infinity,
          child: pw.RichText(
            textAlign: textAlign,
            text: pw.TextSpan(
              children: newTextSpanList,
              style: pw.TextStyle(font: font, fontFallback: fontFallback),
            ),
          ),
        ),
      );
    }
    return nodes;
  }

  Future<Iterable<pw.Widget>> _parseSpecialElements(
    dom.Element element, {
    required String type,
  }) async {
    final localName = element.localName;
    switch (localName) {
      case HTMLTags.h1:
        return [_parseHeadingElement(element, level: 1)];
      case HTMLTags.h2:
        return [_parseHeadingElement(element, level: 2)];
      case HTMLTags.h3:
        return [_parseHeadingElement(element, level: 3)];
      case HTMLTags.h4:
        return [_parseHeadingElement(element, level: 4)];
      case HTMLTags.h5:
        return [_parseHeadingElement(element, level: 5)];
      case HTMLTags.h6:
        return [_parseHeadingElement(element, level: 6)];
      case HTMLTags.unorderedList:
        return _parseUnOrderListElement(element);
      case HTMLTags.orderedList:
        return _parseOrderListElement(element);
      case HTMLTags.table:
        return _parseRawTableData(element);
      case HTMLTags.list:
        return [
          _parseListElement(
            element,
            type: type,
          ),
        ];
      case HTMLTags.paragraph:
        return [await _parseParagraphElement(element)];
      case HTMLTags.image:
        return [await _parseImageElement(element)];
      default:
        return [await _parseParagraphElement(element)];
    }
  }

  Future<Iterable<pw.Widget>> _parseRawTableData(dom.Element element) async {
    List<pw.TableRow> tableRows = [];

    for (dom.Element row in element.querySelectorAll('tr')) {
      List<pw.Widget> rowData = [];
      for (final dom.Element cell in row.children) {
        List<pw.Widget> cellContent = [];
        //NOTE: Handle nested HTML tags within table cells
        for (final dom.Node node in cell.nodes) {
          if (node.nodeType == dom.Node.ELEMENT_NODE) {
            dom.Element element = node as dom.Element;
            if (HTMLTags.formattingElements.contains(element.localName)) {
              final attributes = _parserFormattingElementAttributes(element);
              cellContent.add(
                pw.Text(
                  element.text,
                  style: attributes.$2,
                ),
              );
            }
            if (HTMLTags.specialElements.contains(element.localName)) {
              cellContent.addAll(
                await _parseSpecialElements(
                  element,
                  type: BuiltInAttributeKey.bulletedList,
                ),
              );
            }
          } else if (node.nodeType == dom.Node.TEXT_NODE) {
            cellContent.add(
              pw.Text(
                (node as dom.Text).data,
                style: pw.TextStyle(font: font, fontFallback: fontFallback),
              ),
            );
          }
        }

        rowData.add(pw.Wrap(children: cellContent));
      }
      tableRows.add(pw.TableRow(children: rowData));
    }
    return [
      pw.Table(
        children: tableRows,
        border: pw.TableBorder.all(color: pdf.PdfColors.black),
      ),
    ];
  }

  (pw.TextAlign?, pw.TextStyle) _parserFormattingElementAttributes(
    dom.Element element,
  ) {
    final localName = element.localName;
    pw.TextAlign? textAlign;
    pw.TextStyle attributes =
        pw.TextStyle(fontFallback: fontFallback, font: font);
    final List<pw.TextDecoration> decoration = [];

    switch (localName) {
      case HTMLTags.bold:
      case HTMLTags.strong:
        attributes = attributes.copyWith(fontWeight: pw.FontWeight.bold);
        break;
      case HTMLTags.italic:
      case HTMLTags.em:
        attributes = attributes.copyWith(fontStyle: pw.FontStyle.italic);
        break;
      case HTMLTags.underline:
        decoration.add(pw.TextDecoration.underline);
        break;
      case HTMLTags.del:
        attributes =
            attributes.copyWith(decoration: pw.TextDecoration.lineThrough);
        break;
      /*
      case HTMLTags.span || HTMLTags.mark:
        final deltaAttributes = _getDeltaAttributesFromHTMLAttributes(
              element.attributes,
            ) ??
            {};
        attributes.addAll(deltaAttributes);
        break;
                */
      case HTMLTags.anchor:
        final href = element.attributes['href'];
        if (href != null) {
          decoration.add(pw.TextDecoration.underline);
          attributes = attributes.copyWith(color: pdf.PdfColors.blue);
        }
        break;
      case HTMLTags.code:
        attributes = attributes.copyWith(
          background: const pw.BoxDecoration(color: pdf.PdfColors.grey),
        );
        break;
      default:
        break;
    }
    for (final child in element.children) {
      final formattedAttrs = _parserFormattingElementAttributes(child);
      attributes = attributes.merge(formattedAttrs.$2);
      if (formattedAttrs.$2.decoration != null) {
        decoration.add(formattedAttrs.$2.decoration!);
        textAlign = formattedAttrs.$1;
      }
    }
    return (
      textAlign,
      attributes.copyWith(decoration: pw.TextDecoration.combine(decoration))
    );
  }

  pw.Widget _parseHeadingElement(
    dom.Element element, {
    required int level,
  }) {
    pw.TextAlign? textAlign;
    final textSpan = <pw.TextSpan>[];
    final children = element.nodes.toList();
    for (final child in children) {
      if (child is dom.Element) {
        final attributes = _parserFormattingElementAttributes(child);
        textAlign = attributes.$1;
        textSpan.add(
          pw.TextSpan(
            text: child.text,
            style: attributes.$2,
          ),
        );
      } else {
        textSpan.add(
          pw.TextSpan(
            text: child.text,
            style: pw.TextStyle(font: font, fontFallback: fontFallback),
          ),
        );
      }
    }
    return pw.Header(
      level: level,
      child: pw.RichText(
        textAlign: textAlign,
        text: pw.TextSpan(
          children: textSpan,
          style: pw.TextStyle(
            fontSize: level.getHeadingSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
            fontFallback: fontFallback,
          ),
        ),
      ),
    );
  }

  Iterable<pw.Widget> _parseUnOrderListElement(dom.Element element) {
    final findTodos =
        element.children.where((element) => element.text.contains('['));
    if (findTodos.isNotEmpty) {
      return element.children
          .map(
            (child) => _parseListElement(child, type: TodoListBlockKeys.type),
          )
          .toList();
    } else {
      return element.children
          .map(
            (child) => _parseListElement(
              child,
              type: BulletedListBlockKeys.type,
            ),
          )
          .toList();
    }
  }

  Iterable<pw.Widget> _parseOrderListElement(dom.Element element) {
    return element.children
        .map(
          (child) => _parseListElement(
            child,
            type: NumberedListBlockKeys.type,
          ),
        )
        .toList();
  }

  pw.Widget _parseListElement(
    dom.Element element, {
    required String type,
  }) {
    //TODO: Handle Numbered Lists & Handle nested lists
    if (type == TodoListBlockKeys.type) {
      final bracketRightIndex = element.text.indexOf(']') + 1;
      final strippedString =
          element.text.substring(bracketRightIndex, element.text.length);
      bool condition = false;
      if (element.text.contains('[x]')) {
        condition = true;
      }
      return pw.Row(
        children: [
          pw.Checkbox(
            width: 10,
            height: 10,
            name: element.text.substring(3, 6),
            value: condition,
          ),
          pw.Text(
            strippedString,
            style: pw.TextStyle(font: font, fontFallback: fontFallback),
          ),
        ],
      );
    } else {
      return pw.Bullet(
        text: element.text,
        style: pw.TextStyle(font: font, fontFallback: fontFallback),
      );
    }
  }

  Future<pw.Widget> _parseParagraphElement(dom.Element element) {
    return _parseDeltaElement(element);
  }

  Future<pw.Widget> _parseImageElement(dom.Element element) async {
    final src = element.attributes['src'];
    try {
      if (src != null) {
        if (src.startsWith('https')) {
          final networkImage = await _fetchImage(src);
          return pw.Image(pw.MemoryImage(networkImage));
        } else {
          File localImage = File(src);
          return pw.Image(pw.MemoryImage(await localImage.readAsBytes()));
        }
      } else {
        return pw.Text('');
      }
    } catch (e) {
      return pw.Text(e.toString());
    }
  }

  Future<Uint8List> _fetchImage(String url) async {
    try {
      final Response response = await get(Uri.parse(url));
      return response.bodyBytes;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<pw.Widget> _parseDeltaElement(
    dom.Element element,
  ) async {
    final textSpan = <pw.TextSpan>[];
    final children = element.nodes.toList();
    final subNodes = <pw.Widget>[];
    pw.TextAlign? textAlign;

    for (final child in children) {
      if (child is dom.Element) {
        if (child.children.isNotEmpty &&
            HTMLTags.formattingElements.contains(child.localName) == false) {
          //NOTES:
          //rich editor for webs do this so handling that case for href  <a href="https://www.google.com" rel="noopener noreferrer" target="_blank"><strong><em><u>demo</u></em></strong></a>
          //nodes.addAll(_parseElement(child.children, type: type));
          subNodes.addAll(await _parseElement(child.children));
        } else {
          if (HTMLTags.specialElements.contains(child.localName)) {
            subNodes.addAll(
              await _parseSpecialElements(
                child,
                type: ParagraphBlockKeys.type,
              ),
            );
          } else {
            if (child.localName == HTMLTags.br) {
              textSpan.add(const pw.TextSpan(text: '\n'));
            } else {
              final attributes = _parserFormattingElementAttributes(child);
              textAlign = attributes.$1;
              textSpan.add(
                pw.TextSpan(
                  text: child.text.replaceAll(RegExp(r'\n+$'), ''),
                  style: attributes.$2,
                ),
              );
            }
          }
        }
      } else {
        final attributes =
            _getDeltaAttributesFromHTMLAttributes(element.attributes);
        textAlign = attributes.$1;
        textSpan.add(
          pw.TextSpan(
            text: child.text?.replaceAll(RegExp(r'\n+$'), '') ?? '',
            style: attributes.$2,
          ),
        );
      }
    }
    return pw.Wrap(
      children: [
        pw.SizedBox(
          width: double.infinity,
          child: pw.RichText(
            textAlign: textAlign,
            text: pw.TextSpan(
              children: textSpan,
              style: pw.TextStyle(font: font, fontFallback: fontFallback),
            ),
          ),
        ),
        ...subNodes,
      ],
    );
  }

  static pw.TextStyle _assignTextDecorations(
    pw.TextStyle style,
    String decorationStr,
  ) {
    final decorations = decorationStr.split(" ");
    final textDecorations = <pw.TextDecoration>[];
    for (final type in decorations) {
      if (type == 'line-through') {
        textDecorations.add(pw.TextDecoration.lineThrough);
      } else if (type == 'underline') {
        textDecorations.add(pw.TextDecoration.underline);
      }
    }
    return style.copyWith(
      decoration: pw.TextDecoration.combine(
        textDecorations,
      ),
    );
  }

  (pw.TextAlign?, pw.TextStyle) _getDeltaAttributesFromHTMLAttributes(
    LinkedHashMap<Object, String> htmlAttributes,
  ) {
    pw.TextStyle style = pw.TextStyle(font: font, fontFallback: fontFallback);
    pw.TextAlign? textAlign;
    final cssInlineStyle = htmlAttributes['style'];
    final cssMap = _getCssFromString(cssInlineStyle);

    // font weight
    final fontWeight = cssMap['font-weight'];
    if (fontWeight != null) {
      if (fontWeight == 'bold') {
        style = style.copyWith(fontWeight: pw.FontWeight.bold);
      } else {
        final weight = int.tryParse(fontWeight);
        if (weight != null && weight >= 500) {
          style = style.copyWith(fontWeight: pw.FontWeight.bold);
        }
      }
    }

    // decoration
    final textDecoration = cssMap['text-decoration'];
    if (textDecoration != null) {
      style = _assignTextDecorations(style, textDecoration);
    }

    // background color
    final backgroundColor = cssMap['background-color'];
    if (backgroundColor != null) {
      final highlightColor = ColorExt.fromRgbaString(backgroundColor);
      if (highlightColor != null) {
        style =
            style.copyWith(background: pw.BoxDecoration(color: highlightColor));
      }
    }

    // color
    final color = cssMap['color'];
    if (color != null) {
      final textColor = ColorExt.fromRgbaString(color);
      if (textColor != null) {
        style = style.copyWith(color: textColor);
      }
    }

    // italic
    final fontStyle = cssMap['font-style'];
    if (fontStyle == 'italic') {
      style = style.copyWith(fontStyle: pw.FontStyle.italic);
    }

    // text align
    final alignment = cssMap['text-align'];
    if (alignment != null) {
      textAlign = _alignText(alignment);
    }

    return (textAlign, style);
  }

  static pw.TextAlign _alignText(String alignment) {
    switch (alignment) {
      case 'right':
        return pw.TextAlign.right;
      case 'center':
        return pw.TextAlign.center;
      case 'left':
        return pw.TextAlign.left;
      case 'justify':
        return pw.TextAlign.justify;
      default:
        return pw.TextAlign.left;
    }
  }

  static Map<String, String> _getCssFromString(String? cssString) {
    final Map<String, String> result = {};
    if (cssString == null) {
      return result;
    }
    final entries = cssString.split(';');
    for (final entry in entries) {
      final tuples = entry.split(':');
      if (tuples.length < 2) {
        continue;
      }
      result[tuples[0].trim()] = tuples[1].trim();
    }
    return result;
  }
}

extension HeaderSize on int {
  double get getHeadingSize {
    switch (this) {
      case 1:
        return 32;
      case 2:
        return 28;
      case 3:
        return 20;
      case 4:
        return 17;
      case 5:
        return 14;
      case 6:
        return 10;
      default:
        return 32;
    }
  }
}
