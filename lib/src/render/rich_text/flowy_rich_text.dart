import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

const _kRichTextDebugMode = false;

typedef FlowyTextSpanDecorator = TextSpan Function(TextSpan textSpan);

class FlowyRichText extends StatefulWidget {
  const FlowyRichText({
    Key? key,
    this.cursorHeight,
    this.cursorWidth = 1.5,
    this.lineHeight = 1.0,
    this.textSpanDecorator,
    this.placeholderText = ' ',
    this.placeholderTextSpanDecorator,
    required this.node,
    required this.editorState,
  }) : super(key: key);

  final Node node;
  final EditorState editorState;
  final double? cursorHeight;
  final double cursorWidth;
  final double lineHeight;
  final FlowyTextSpanDecorator? textSpanDecorator;
  final String placeholderText;
  final FlowyTextSpanDecorator? placeholderTextSpanDecorator;

  @override
  State<FlowyRichText> createState() => _FlowyRichTextState();
}

class _FlowyRichTextState extends State<FlowyRichText> with SelectableMixin {
  var _textKey = GlobalKey();
  final _placeholderTextKey = GlobalKey();

  RenderParagraph get _renderParagraph =>
      _textKey.currentContext?.findRenderObject() as RenderParagraph;

  RenderParagraph? get _placeholderRenderParagraph =>
      _placeholderTextKey.currentContext?.findRenderObject()
          as RenderParagraph?;

  @override
  void didUpdateWidget(covariant FlowyRichText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // https://github.com/flutter/flutter/issues/110342
    if (_textKey.currentWidget is RichText) {
      // Force refresh the RichText widget.
      _textKey = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildRichText(context);
  }

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(
        path: widget.node.path,
        offset: widget.node.delta?.toPlainText().length ?? 0,
      );

  @override
  Rect? getCursorRectInPosition(Position position) {
    final textPosition = TextPosition(offset: position.offset);

    var cursorHeight = _renderParagraph.getFullHeightForCaret(textPosition);
    var cursorOffset =
        _renderParagraph.getOffsetForCaret(textPosition, Rect.zero);
    if (cursorHeight == null) {
      cursorHeight =
          _placeholderRenderParagraph?.getFullHeightForCaret(textPosition);
      cursorOffset = _placeholderRenderParagraph?.getOffsetForCaret(
            textPosition,
            Rect.zero,
          ) ??
          Offset.zero;
    }
    if (widget.cursorHeight != null && cursorHeight != null) {
      cursorOffset = Offset(
        cursorOffset.dx,
        cursorOffset.dy + (cursorHeight - widget.cursorHeight!) / 2,
      );
      cursorHeight = widget.cursorHeight;
    }
    final rect = Rect.fromLTWH(
      cursorOffset.dx - (widget.cursorWidth / 2.0),
      cursorOffset.dy,
      widget.cursorWidth,
      cursorHeight ?? 16.0,
    );
    return rect;
  }

  @override
  Position getPositionInOffset(Offset start) {
    final offset = _renderParagraph.globalToLocal(start);
    final baseOffset = _renderParagraph.getPositionForOffset(offset).offset;
    return Position(path: widget.node.path, offset: baseOffset);
  }

  @override
  Selection? getWordBoundaryInOffset(Offset offset) {
    final localOffset = _renderParagraph.globalToLocal(offset);
    final textPosition = _renderParagraph.getPositionForOffset(localOffset);
    final textRange = _renderParagraph.getWordBoundary(textPosition);
    final start = Position(path: widget.node.path, offset: textRange.start);
    final end = Position(path: widget.node.path, offset: textRange.end);
    return Selection(start: start, end: end);
  }

  @override
  Selection? getWordBoundaryInPosition(Position position) {
    final textPosition = TextPosition(offset: position.offset);
    final textRange = _renderParagraph.getWordBoundary(textPosition);
    final start = Position(path: widget.node.path, offset: textRange.start);
    final end = Position(path: widget.node.path, offset: textRange.end);
    return Selection(start: start, end: end);
  }

  @override
  List<Rect> getRectsInSelection(Selection selection) {
    final textSelection = textSelectionFromEditorSelection(selection);
    if (textSelection == null) {
      return [];
    }
    final rects = _renderParagraph
        .getBoxesForSelection(textSelection, boxHeightStyle: BoxHeightStyle.max)
        .map((box) => box.toRect())
        .toList(growable: false);
    if (rects.isEmpty) {
      // If the rich text widget does not contain any text,
      // there will be no selection boxes,
      // so we need to return to the default selection.
      return [Rect.fromLTWH(0, 0, 0, _renderParagraph.size.height)];
    }
    return rects;
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    final localStart = _renderParagraph.globalToLocal(start);
    final localEnd = _renderParagraph.globalToLocal(end);
    final baseOffset = _renderParagraph.getPositionForOffset(localStart).offset;
    final extentOffset = _renderParagraph.getPositionForOffset(localEnd).offset;
    return Selection.single(
      path: widget.node.path,
      startOffset: baseOffset,
      endOffset: extentOffset,
    );
  }

  @override
  Offset localToGlobal(Offset offset) {
    return _renderParagraph.localToGlobal(offset);
  }

  Widget _buildRichText(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: widget.node.delta?.toPlainText().isEmpty ?? true
          ? Stack(
              children: [
                _buildPlaceholderText(context),
                _buildSingleRichText(context),
              ],
            )
          : _buildSingleRichText(context),
    );
  }

  Widget _buildPlaceholderText(BuildContext context) {
    final textSpan = _placeholderTextSpan;
    return RichText(
      key: _placeholderTextKey,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      text: widget.placeholderTextSpanDecorator != null
          ? widget.placeholderTextSpanDecorator!(textSpan)
          : textSpan,
    );
  }

  Widget _buildSingleRichText(BuildContext context) {
    final textSpan = _textSpan;
    return RichText(
      key: _textKey,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      text: widget.textSpanDecorator != null
          ? widget.textSpanDecorator!(textSpan)
          : textSpan,
    );
  }

  TextSpan get _placeholderTextSpan {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.placeholderText,
          style: widget.editorState.editorStyle.textStyleConfiguration.text,
        ),
      ],
    );
  }

  TextSpan get _textSpan {
    var offset = 0;
    List<TextSpan> textSpans = [];
    final style = widget.editorState.editorStyle.textStyleConfiguration;
    final textInserts = widget.node.delta!.whereType<TextInsert>();
    for (final textInsert in textInserts) {
      var textStyle = style.text;
      GestureRecognizer? recognizer;
      final attributes = textInsert.attributes;
      if (attributes != null) {
        if (attributes.bold == true) {
          textStyle = textStyle.combine(style.bold);
        }
        if (attributes.italic == true) {
          textStyle = textStyle.combine(style.italic);
        }
        if (attributes.underline == true) {
          textStyle = textStyle.combine(style.underline);
        }
        if (attributes.strikethrough == true) {
          textStyle = textStyle.combine(style.strikethrough);
        }
        if (attributes.href != null) {
          textStyle = textStyle.combine(style.href);
          recognizer = _buildTapHrefGestureRecognizer(
            attributes.href!,
            Selection.single(
              path: widget.node.path,
              startOffset: offset,
              endOffset: offset + textInsert.length,
            ),
          );
        }
        if (attributes.code == true) {
          textStyle = textStyle.combine(style.code);
        }
        if (attributes.backgroundColor != null) {
          textStyle = textStyle.combine(
            TextStyle(backgroundColor: attributes.backgroundColor),
          );
        }
        if (attributes.color != null) {
          textStyle = textStyle.combine(
            TextStyle(color: attributes.color),
          );
        }
      }
      offset += textInsert.length;
      textSpans.add(
        TextSpan(
          text: textInsert.text,
          style: textStyle,
          recognizer: recognizer,
        ),
      );
    }
    if (_kRichTextDebugMode) {
      textSpans.add(
        TextSpan(
          text: '${widget.node.path}',
          style: const TextStyle(
            backgroundColor: Colors.red,
            fontSize: 16.0,
          ),
        ),
      );
    }
    return TextSpan(
      children: textSpans,
    );
  }

  GestureRecognizer _buildTapHrefGestureRecognizer(
    String href,
    Selection selection,
  ) {
    Timer? timer;
    var tapCount = 0;
    final tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // implement a simple double tap logic
        tapCount += 1;
        timer?.cancel();

        if (tapCount == 2 || !widget.editorState.editable) {
          tapCount = 0;
          safeLaunchUrl(href);
          return;
        }

        timer = Timer(const Duration(milliseconds: 200), () {
          tapCount = 0;
          widget.editorState.service.selectionService
              .updateSelection(selection);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showLinkMenu(context, widget.editorState, selection, true);
          });
        });
      };
    return tapGestureRecognizer;
  }

  TextSelection? textSelectionFromEditorSelection(Selection? selection) {
    if (selection == null) {
      return null;
    }

    final normalized = selection.normalized;
    final path = widget.node.path;
    if (path < normalized.start.path || path > normalized.end.path) {
      return null;
    }

    final length = widget.node.delta?.length;
    if (length == null) {
      return null;
    }

    TextSelection? textSelection;

    if (normalized.isSingle) {
      if (path.equals(normalized.start.path)) {
        if (normalized.isCollapsed) {
          textSelection = TextSelection.collapsed(
            offset: normalized.startIndex,
          );
        } else {
          textSelection = TextSelection(
            baseOffset: normalized.startIndex,
            extentOffset: normalized.endIndex,
          );
        }
      }
    } else {
      if (path.equals(normalized.start.path)) {
        textSelection = TextSelection(
          baseOffset: normalized.startIndex,
          extentOffset: length,
        );
      } else if (path.equals(normalized.end.path)) {
        textSelection = TextSelection(
          baseOffset: 0,
          extentOffset: normalized.endIndex,
        );
      } else {
        textSelection = TextSelection(
          baseOffset: 0,
          extentOffset: length,
        );
      }
    }
    return textSelection;
  }
}
