import 'dart:collection';
import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:markdown/markdown.dart' as md;

class PdfHTMLEncoder extends Converter<String, pw.Document> {
  PdfHTMLEncoder();

  @override
  pw.Document convert(String input) {
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
    final nodes = _parseElement(body.nodes);
    /*
    return Document.blank(withInitialText: false)
      ..insert(
        [0],
        nodes,
      );
        */
    final newPdf = pw.Document();
    newPdf.addPage(
      pw.MultiPage(build: (pw.Context context) => nodes.toList()),
    );
    return newPdf;
  }

  Iterable<pw.Widget> _parseElement(
    Iterable<dom.Node> domNodes, {
    String? type,
  }) {
    final delta = Delta();
    final List<pw.Widget> nodes = [];
    for (final domNode in domNodes) {
      if (domNode is dom.Element) {
        final localName = domNode.localName;
        if (HTMLTags.formattingElements.contains(localName)) {
          final attributes = _parserFormattingElementAttributes(domNode);
          //delta.insert(domNode.text, attributes: attributes);
//TODO: add attribues
          nodes.add(pw.Paragraph(text: domNode.text, style: attributes.first));
        } else if (HTMLTags.specialElements.contains(localName)) {
          if (delta.isNotEmpty) {
            //TODO: add styles later attributes
            nodes.add(pw.Paragraph(text: domNode.text));
          }
          nodes.addAll(
            _parseSpecialElements(
              domNode,
              type: type ?? ParagraphBlockKeys.type,
            ),
          );
          /*
          nodes.addAll(
            _parseSpecialElements(
              domNode,
              type: type ?? ParagraphBlockKeys.type,
            ),
          );
          */
        }
      } else if (domNode is dom.Text) {
        // skip the empty text node
        if (domNode.text.trim().isEmpty) {
          continue;
        }
        //delta.insert(domNode.text);

        nodes.add(pw.Paragraph(text: domNode.text));
      } else {
        assert(false, 'Unknown node type: $domNode');
      }
    }
    /*
    if (delta.isNotEmpty) {
      nodes.add(pw.Paragraph(text: domNode.text));
    }
        */
    return nodes;
  }

  Iterable<pw.Widget> _parseSpecialElements(
    dom.Element element, {
    required String type,
  }) {
    final localName = element.localName;
    switch (localName) {
      case HTMLTags.h1:
        return _parseHeadingElement(element, level: 1);
      case HTMLTags.h2:
        return _parseHeadingElement(element, level: 2);
      case HTMLTags.h3:
        return _parseHeadingElement(element, level: 3);
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
        return _parseParagraphElement(element);

      /*
      case HTMLTags.blockQuote:
        return [_parseBlockQuoteElement(element)];
      case HTMLTags.image:
        return [_parseImageElement(element)];
            */
      default:
        return _parseParagraphElement(element);
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
      /*
TODO: Uncomment this
      nodes.addAll(
        _parseSpecialElements(
          element,
          type: ParagraphBlockKeys.type,
        ),
      );
*/
    } else if (element is dom.Text) {
      // skip the empty text node

      delta.insert(element.text);
    }

    if (delta.isNotEmpty) {
      nodes.add(paragraphNode(delta: delta));
    }
    return nodes;
  }

//TODO: Change it to TextStyle
  List<pw.TextStyle> _parserFormattingElementAttributes(
    dom.Element element,
  ) {
    final localName = element.localName;

    List<pw.TextStyle> attributes = [];
    switch (localName) {
      case HTMLTags.bold || HTMLTags.strong:
        attributes = [pw.TextStyle(fontWeight: pw.FontWeight.bold)];
        break;
      case HTMLTags.italic || HTMLTags.em:
        attributes = [pw.TextStyle(fontStyle: pw.FontStyle.italic)];
        break;
        /*
      case HTMLTags.underline:
        attributes = [pw.TextStyle(fontStyle: pw.FontStyle.underline)];
                */
        break;
        /*
      case HTMLTags.del:
        attributes = {AppFlowyRichTextKeys.strikethrough: true};
                */
        break;
        /*
      case HTMLTags.code:
        attributes = {AppFlowyRichTextKeys.code: true};
                */
        /*
      case HTMLTags.span || HTMLTags.mark:
        final deltaAttributes = _getDeltaAttributesFromHTMLAttributes(
              element.attributes,
            ) ??
            {};
        attributes.addAll(deltaAttributes);
                */
        break;
      case HTMLTags.anchor:
        final href = element.attributes['href'];
        if (href != null) {
          attributes = [];
        }
        break;

      case HTMLTags.strikethrough:
        attributes = [];
        break;
      default:
        break;
    }
    for (final child in element.children) {
      attributes.addAll(_parserFormattingElementAttributes(child));
    }
    return attributes;
  }

  Iterable<pw.Widget> _parseHeadingElement(
    dom.Element element, {
    required int level,
  }) {
    //final (delta, specialNodes) = _parseDeltaElement(element);
    final d = _parseDeltaElement(element);
    return d;
/*
    return [
      pw.Header(text: element.text, level: level)
        */
/*
      headingNode(
        level: level,
        delta: delta,
      ),
      ...specialNodes,

    ];
            */
  }
/*
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

  pw.Widget _parseListElement(
    dom.Element element, {
    required String type,
  }) {
    print(type);
    if (type == TodoListBlockKeys.type) {
      //Handle Numbered Lists
      final strippedString = element.text.indexOf(']') + 1;
      final strippedString_2 =
          element.text.substring(strippedString, element.text.length);
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
              value: condition),
          pw.Text(strippedString_2),
        ],
      );
    } else {
      return pw.Bullet(text: element.text);
    }
    //final (delta, node) = _parseDeltaElement(element, type: type);
    /*
    return Node(
      type: type,
      children: node,
      attributes: {ParagraphBlockKeys.delta: delta.toJson()},
    );
        */
  }

  Iterable<pw.Paragraph> _parseParagraphElement(dom.Element element) {
    //final (delta, specialNodes) = _parseDeltaElement(element);
    return [pw.Paragraph(text: element.text)];
    //return [paragraphNode(delta: delta), ...specialNodes];
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

  Iterable<pw.Widget> _parseDeltaElement(
    dom.Element element, {
    String? type,
  }) {
    final delta = Delta();
    final nodes = <pw.Widget>[];
    final children = element.nodes.toList();
    int idx = 0;

    for (final child in children) {
      if (child is dom.Element) {
        if (child.children.isNotEmpty &&
            HTMLTags.formattingElements.contains(child.localName) == false) {
          //rich editor for webs do this so handling that case for href  <a href="https://www.google.com" rel="noopener noreferrer" target="_blank"><strong><em><u>demo</u></em></strong></a>

          //nodes.addAll(_parseElement(child.children, type: type));
        } else {
          if (HTMLTags.specialElements.contains(child.localName)) {
            nodes.addAll(
              _parseSpecialElements(
                child,
                type: ParagraphBlockKeys.type,
              ),
            );
          } else {
            final attributes = _parserFormattingElementAttributes(child);
            /*
            delta.insert(
              child.text.replaceAll(RegExp(r'\n+$'), ''),
              attributes: attributes,
            );
            */
            nodes.add(
              pw.Text(
                child.text.replaceAll(RegExp(r'\n+$'), ''),
                style: attributes.first,
              ),
            );
          }
        }
      } else {
        nodes.add(pw.Text(child.text?.replaceAll(RegExp(r'\n+$'), '') ?? ''));
      }
      idx++;
    }
    return nodes;
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
