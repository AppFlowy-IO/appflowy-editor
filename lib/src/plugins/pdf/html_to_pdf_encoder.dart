import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;

/// This class handles conversion from html to pdf
class PdfHTMLEncoder {
  final pw.Font? font;
  final List<pw.Font> fontFallback;
  PdfHTMLEncoder({
    this.font,
    required this.fontFallback,
  });

  Future<pw.Document> convert(String input) async {
    final document = parse(input);
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
          //delta.insert(domNode.text, attributes: attributes);
//TODO: add attribues
          nodes.add(pw.Paragraph(text: domNode.text, style: attributes.$2));
        } else if (HTMLTags.specialElements.contains(localName)) {
          if (textSpan.isNotEmpty) {
            //TODO: add styles later attributes
            final newTextSpanList = List<pw.TextSpan>.from(textSpan);
            nodes.add(
              (pw.SizedBox(
                width: double.infinity,
                child: pw.RichText(
                  textAlign: textAlign,
                  text: pw.TextSpan(children: newTextSpanList),
                ),
              )),
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
            (pw.SizedBox(
              width: double.infinity,
              child: pw.RichText(
                textAlign: textAlign,
                text: pw.TextSpan(children: newTextSpanList),
              ),
            )),
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
        (pw.SizedBox(
          width: double.infinity,
          child: pw.RichText(
            textAlign: textAlign,
            text: pw.TextSpan(children: newTextSpanList),
          ),
        )),
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
      /*
      case HTMLTags.table:
        return _parseTable(element);
            */
      case HTMLTags.list:
        return [
          _parseListElement(
            element,
            type: type,
          ),
        ];
      case HTMLTags.paragraph:
        return [await _parseParagraphElement(element)];

      /*
      case HTMLTags.blockQuote:
        return [_parseBlockQuoteElement(element)];
      case HTMLTags.image:
        return [_parseImageElement(element)];
            */
      default:
        return [await _parseParagraphElement(element)];
    }
  }

  Iterable<Node> _parseTable(dom.Element element) {
    final List<Node> tablenodes = [];
    int columnLenth = 0;
    int rowLength = 0;
    for (final data in element.children) {
      final (col, row, rwdata) = _parsetableRows(data);
      columnLenth = columnLenth + col;
      rowLength = rowLength + row;

      tablenodes.addAll(rwdata);
    }

    return [
      TableNode(
        node: Node(
          type: TableBlockKeys.type,
          attributes: {
            TableBlockKeys.rowsLen: rowLength,
            TableBlockKeys.colsLen: columnLenth,
            TableBlockKeys.colDefaultWidth: TableDefaults.colWidth,
            TableBlockKeys.rowDefaultHeight: TableDefaults.rowHeight,
            TableBlockKeys.colMinimumWidth: TableDefaults.colMinimumWidth,
          },
          children: tablenodes,
        ),
      ).node,
    ];
  }

  (int, int, List<Node>) _parsetableRows(dom.Element element) {
    final List<Node> nodes = [];
    int colLength = 0;
    int rowLength = 0;

    for (final data in element.children) {
      final tabledata = _parsetableData(data, rowPosition: rowLength);
      if (colLength == 0) {
        colLength = tabledata.length;
      }
      nodes.addAll(tabledata);
      rowLength++;
    }
    return (colLength, rowLength, nodes);
  }

  Iterable<Node> _parsetableData(
    dom.Element element, {
    required int rowPosition,
  }) {
    final List<Node> nodes = [];
    int columnPosition = 0;

    for (final data in element.children) {
      Attributes attributes = {
        TableCellBlockKeys.colPosition: columnPosition,
        TableCellBlockKeys.rowPosition: rowPosition,
      };
      if (data.attributes.isNotEmpty) {
        final deltaAttributes = _getDeltaAttributesFromHTMLAttributes(
              element.attributes,
            ) ??
            {};
        attributes.addAll(deltaAttributes);
      }

      List<Node> children;
      if (data.children.isEmpty) {
        children = [paragraphNode(text: data.text)];
      } else {
        children = _parseTableSpecialNodes(data).toList();
      }

      final node = Node(
        type: TableCellBlockKeys.type,
        attributes: attributes,
        children: children,
      );

      nodes.add(node);
      columnPosition++;
    }

    return nodes;
  }

  Iterable<Node> _parseTableSpecialNodes(dom.Element element) {
    final List<Node> nodes = [];

    if (element.children.isNotEmpty) {
      for (final childrens in element.children) {
        nodes.addAll(_parseTableDataElementsData(childrens));
      }
    } else {
      nodes.addAll(_parseTableDataElementsData(element));
    }
    return nodes;
  }

  List<Node> _parseTableDataElementsData(dom.Element element) {
    final List<Node> nodes = [];
    final delta = Delta();
    final localName = element.localName;

    if (HTMLTags.formattingElements.contains(localName)) {
      final attributes = _parserFormattingElementAttributes(element);
      //delta.insert(element.text, attributes: attributes);
    } else if (HTMLTags.specialElements.contains(localName)) {
      if (delta.isNotEmpty) {
        nodes.add(paragraphNode(delta: delta));
      }
    } else if (element is dom.Text) {
      delta.insert(element.text);
    }

    if (delta.isNotEmpty) {
      nodes.add(paragraphNode(delta: delta));
    }
    return nodes;
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
      case HTMLTags.bold || HTMLTags.strong:
        attributes = attributes.copyWith(fontWeight: pw.FontWeight.bold);
        break;
      case HTMLTags.italic || HTMLTags.em:
        attributes = attributes.copyWith(fontStyle: pw.FontStyle.italic);
        break;
      case HTMLTags.underline:
        decoration.add(pw.TextDecoration.underline);
        break;
      /*
      case HTMLTags.del:
        attributes = {AppFlowyRichTextKeys.strikethrough: true};
        break;

                */
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
        textSpan.add(pw.TextSpan(text: child.text, style: attributes.$2));
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
          ),
        ),
      ),
    );
  }
/*
//TODO: Support callout & Qoute block
  Node _parseBlockQuoteElement(dom.Element element) {
    final (delta, nodes) = _parseDeltaElement(element);
    return quoteNode(
      delta: delta,
      children: nodes,
    );
  }
*/

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
            (child) =>
                _parseListElement(child, type: BulletedListBlockKeys.type),
          )
          .toList();
    }
  }

  Iterable<pw.Widget> _parseOrderListElement(dom.Element element) {
    return element.children
        .map(
          (child) => _parseListElement(child, type: NumberedListBlockKeys.type),
        )
        .toList();
  }

//TODO: Handle nested lists
  pw.Widget _parseListElement(
    dom.Element element, {
    required String type,
  }) {
    //TODO: Handle Numbered Lists
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
      return pw.Bullet(text: element.text);
    }
  }

  Future<pw.Widget> _parseParagraphElement(dom.Element element) {
    final textSpan = _parseDeltaElement(element);
    return textSpan;
  }

  //TODO: Support image...
  Node _parseImageElement(dom.Element element) {
    final src = element.attributes['src'];
    if (src == null || src.isEmpty || !src.startsWith('http')) {
      return paragraphNode(); // return empty paragraph
    }
    // only support network image
    return imageNode(
      url: src,
    );
  }

  Future<pw.Widget> _parseDeltaElement(
    dom.Element element, {
    String? type,
  }) async {
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
              textSpan.add(
                const pw.TextSpan(text: '\n'),
              );
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
        //TODO: Add HTML attributes
        textSpan.add(
          pw.TextSpan(
            text: child.text?.replaceAll(RegExp(r'\n+$'), '') ?? '',
            style: pw.TextStyle(font: font, fontFallback: fontFallback),
          ),
        );
      }
    }
    return pw.Wrap(
      children: [
        pw.SizedBox(
          width: double.infinity,
          child: pw.RichText(
            text: pw.TextSpan(children: textSpan),
          ),
        ),
        ...subNodes,
      ],
    );
  }

  Attributes? _getDeltaAttributesFromHTMLAttributes(
    LinkedHashMap<Object, String> htmlAttributes,
  ) {
    final Attributes attributes = {};
    final style = htmlAttributes['style'];
    final css = _getCssFromString(style);

    // font weight
    final fontWeight = css['font-weight'];
    if (fontWeight != null) {
      if (fontWeight == 'bold') {
        attributes[AppFlowyRichTextKeys.bold] = true;
      } else {
        final weight = int.tryParse(fontWeight);
        if (weight != null && weight >= 500) {
          attributes[AppFlowyRichTextKeys.bold] = true;
        }
      }
    }

    // decoration
    final textDecoration = css['text-decoration'];
    if (textDecoration != null) {
      final decorations = textDecoration.split(' ');
      for (final decoration in decorations) {
        switch (decoration) {
          case 'underline':
            attributes[AppFlowyRichTextKeys.underline] = true;
            break;
          case 'line-through':
            attributes[AppFlowyRichTextKeys.strikethrough] = true;
            break;
          default:
            break;
        }
      }
    }

    // background color
    final backgroundColor = css['background-color'];
    if (backgroundColor != null) {
      final highlightColor = backgroundColor.tryToColor()?.toHex();
      if (highlightColor != null) {
        attributes[AppFlowyRichTextKeys.highlightColor] = highlightColor;
      }
    }

    // background
    final background = css['background'];
    if (background != null) {
      final highlightColor = background.tryToColor()?.toHex();
      if (highlightColor != null) {
        attributes[AppFlowyRichTextKeys.highlightColor] = highlightColor;
      }
    }

    // color
    final color = css['color'];
    if (color != null) {
      final textColor = color.tryToColor()?.toHex();
      if (textColor != null) {
        attributes[AppFlowyRichTextKeys.textColor] = textColor;
      }
    }

    // italic
    final fontStyle = css['font-style'];
    if (fontStyle == 'italic') {
      attributes[AppFlowyRichTextKeys.italic] = true;
    }

    return attributes.isEmpty ? null : attributes;
  }

  Map<String, String> _getCssFromString(String? cssString) {
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
