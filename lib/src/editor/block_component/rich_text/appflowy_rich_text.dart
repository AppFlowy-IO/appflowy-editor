import 'dart:math';
import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef TextSpanDecoratorForAttribute = InlineSpan Function(
  BuildContext context,
  Node node,
  int index,
  TextInsert text,
  TextSpan before,
  TextSpan after,
);

typedef AppFlowyTextSpanDecorator = TextSpan Function(TextSpan textSpan);
typedef AppFlowyAutoCompleteTextProvider = String? Function(
  BuildContext context,
  Node node,
  TextSpan? textSpan,
);

class AppFlowyRichText extends StatefulWidget {
  const AppFlowyRichText({
    super.key,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.lineHeight,
    this.textSpanDecorator,
    this.placeholderText = ' ',
    this.placeholderTextSpanDecorator,
    this.textDirection = TextDirection.ltr,
    this.textSpanDecoratorForCustomAttributes,
    this.textAlign,
    this.cursorColor = const Color.fromARGB(255, 0, 0, 0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    this.autoCompleteTextProvider,
    required this.delegate,
    required this.node,
    required this.editorState,
  });

  /// The node of the rich text.
  final Node node;

  /// The editor state.
  final EditorState editorState;

  /// The height of the cursor.
  ///
  /// If this is null, the height of the cursor will be calculated automatically.
  final double? cursorHeight;

  /// The width of the cursor.
  final double cursorWidth;

  /// The height of each line.
  final double? lineHeight;

  /// customize the text span for rich text
  final AppFlowyTextSpanDecorator? textSpanDecorator;

  /// The placeholder text when the rich text is empty.
  final String placeholderText;

  /// customize the text span for placeholder text
  final AppFlowyTextSpanDecorator? placeholderTextSpanDecorator;

  final TextAlign? textAlign;

  // get the cursor rect, selection rects or block rect from the delegate
  final SelectableMixin delegate;

  // this span will be appended to the current text span, mostly, it is used for auto complete
  final AppFlowyAutoCompleteTextProvider? autoCompleteTextProvider;

  /// customize the text span for custom attributes
  ///
  /// You can use this to customize the text span for custom attributes
  ///   or override the existing one.
  final TextSpanDecoratorForAttribute? textSpanDecoratorForCustomAttributes;
  final TextDirection textDirection;

  final Color cursorColor;
  final Color selectionColor;

  @override
  State<AppFlowyRichText> createState() => _AppFlowyRichTextState();
}

class _AppFlowyRichTextState extends State<AppFlowyRichText>
    with SelectableMixin {
  final textKey = GlobalKey();
  final placeholderTextKey = GlobalKey();

  RenderParagraph? get _renderParagraph =>
      textKey.currentContext?.findRenderObject() as RenderParagraph?;

  RenderParagraph? get _placeholderRenderParagraph =>
      placeholderTextKey.currentContext?.findRenderObject() as RenderParagraph?;

  TextSpanDecoratorForAttribute? get textSpanDecoratorForAttribute =>
      widget.textSpanDecoratorForCustomAttributes ??
      widget.editorState.editorStyle.textSpanDecorator;

  AppFlowyAutoCompleteTextProvider? get autoCompleteTextProvider =>
      widget.autoCompleteTextProvider ??
      widget.editorState.autoCompleteTextProvider;
  bool get enableAutoComplete =>
      widget.editorState.enableAutoComplete && autoCompleteTextProvider != null;

  TextStyleConfiguration get textStyleConfiguration =>
      widget.editorState.editorStyle.textStyleConfiguration;

  @override
  Widget build(BuildContext context) {
    Widget child = _buildRichText(context);

    final delta = widget.node.delta;
    if (delta == null || delta.isEmpty) {
      child = Stack(
        children: [
          _buildPlaceholderText(context),
          _buildRichText(context),
        ],
      );
    }

    if (enableAutoComplete) {
      final autoCompleteText = _buildAutoCompleteRichText();
      child = Stack(
        children: [
          autoCompleteText,
          child,
        ],
      );
    }

    return BlockSelectionContainer(
      delegate: widget.delegate,
      listenable: widget.editorState.selectionNotifier,
      remoteSelection: widget.editorState.remoteSelections,
      node: widget.node,
      cursorColor: widget.cursorColor,
      selectionColor: widget.selectionColor,
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: child,
      ),
    );
  }

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(
        path: widget.node.path,
        offset: widget.node.delta?.toPlainText().length ?? 0,
      );

  @override
  Rect getBlockRect({
    bool shiftWithBaseOffset = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    if (kDebugMode && _renderParagraph?.debugNeedsLayout == true) {
      return null;
    }

    final delta = widget.node.delta;
    if (position.offset < 0 ||
        (delta != null && position.offset > delta.length)) {
      return null;
    }

    final textPosition = TextPosition(offset: position.offset);
    var cursorHeight = _renderParagraph?.getFullHeightForCaret(textPosition);
    var cursorOffset =
        _renderParagraph?.getOffsetForCaret(textPosition, Rect.zero) ??
            Offset.zero;
    if (cursorHeight == null) {
      cursorHeight =
          _placeholderRenderParagraph?.getFullHeightForCaret(textPosition);
      cursorOffset = _placeholderRenderParagraph?.getOffsetForCaret(
            textPosition,
            Rect.zero,
          ) ??
          Offset.zero;
      if (textDirection() == TextDirection.rtl) {
        if (widget.placeholderText.trim().isNotEmpty) {
          cursorOffset = cursorOffset.translate(
            _placeholderRenderParagraph?.size.width ?? 0,
            0,
          );
        }
      }
    }
    if (widget.cursorHeight != null && cursorHeight != null) {
      cursorOffset = Offset(
        cursorOffset.dx,
        cursorOffset.dy + (cursorHeight - widget.cursorHeight!) / 2,
      );
      cursorHeight = widget.cursorHeight;
    }
    final rect = Rect.fromLTWH(
      max(0, cursorOffset.dx - (widget.cursorWidth / 2.0)),
      cursorOffset.dy,
      widget.cursorWidth,
      cursorHeight ?? 16.0,
    );
    return rect;
  }

  @override
  Position getPositionInOffset(Offset start) {
    final offset = _renderParagraph?.globalToLocal(start) ?? Offset.zero;
    final baseOffset =
        _renderParagraph?.getPositionForOffset(offset).offset ?? -1;
    return Position(path: widget.node.path, offset: baseOffset);
  }

  @override
  Selection? getWordBoundaryInOffset(Offset offset) {
    final localOffset = _renderParagraph?.globalToLocal(offset) ?? Offset.zero;
    final textPosition = _renderParagraph?.getPositionForOffset(localOffset) ??
        const TextPosition(offset: 0);
    final textRange =
        _renderParagraph?.getWordBoundary(textPosition) ?? TextRange.empty;
    final start = Position(path: widget.node.path, offset: textRange.start);
    final end = Position(path: widget.node.path, offset: textRange.end);
    return Selection(start: start, end: end);
  }

  @override
  Selection? getWordBoundaryInPosition(Position position) {
    final textPosition = TextPosition(offset: position.offset);
    final textRange =
        _renderParagraph?.getWordBoundary(textPosition) ?? TextRange.empty;
    final start = Position(path: widget.node.path, offset: textRange.start);
    final end = Position(path: widget.node.path, offset: textRange.end);
    return Selection(start: start, end: end);
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    if (kDebugMode && _renderParagraph?.debugNeedsLayout == true) {
      return [];
    }
    final textSelection = textSelectionFromEditorSelection(selection);
    if (textSelection == null) {
      return [];
    }
    final rects = _renderParagraph
        ?.getBoxesForSelection(
          textSelection,
          boxHeightStyle: BoxHeightStyle.max,
        )
        .map((box) => box.toRect())
        .toList(growable: false);

    if (rects == null || rects.isEmpty) {
      // If the rich text widget does not contain any text,
      // there will be no selection boxes,
      // so we need to return to the default selection.
      return [Rect.fromLTWH(0, 0, 0, _renderParagraph?.size.height ?? 0)];
    }
    return rects;
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    final delta = widget.node.delta;
    if (delta == null) {
      return Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 0,
      );
    }
    final localStart = _renderParagraph?.globalToLocal(start) ?? Offset.zero;
    final localEnd = _renderParagraph?.globalToLocal(end) ?? Offset.zero;
    final baseOffset =
        _renderParagraph?.getPositionForOffset(localStart).offset ?? -1;
    final extentOffset =
        _renderParagraph?.getPositionForOffset(localEnd).offset ?? -1;
    return Selection.single(
      path: widget.node.path,
      startOffset: baseOffset,
      endOffset: extentOffset,
    );
  }

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) {
    return _renderParagraph?.localToGlobal(offset) ?? Offset.zero;
  }

  @override
  TextDirection textDirection() {
    return widget.textDirection;
  }

  Widget _buildPlaceholderText(BuildContext context) {
    final textSpan = getPlaceholderTextSpan();
    return RichText(
      key: placeholderTextKey,
      textHeightBehavior: TextHeightBehavior(
        applyHeightToFirstAscent:
            textStyleConfiguration.applyHeightToFirstAscent,
        applyHeightToLastDescent:
            textStyleConfiguration.applyHeightToLastDescent,
      ),
      text: widget.placeholderTextSpanDecorator != null
          ? widget.placeholderTextSpanDecorator!(textSpan)
          : textSpan,
      textDirection: textDirection(),
      textScaler:
          TextScaler.linear(widget.editorState.editorStyle.textScaleFactor),
    );
  }

  Widget _buildRichText(BuildContext context) {
    final textInserts = widget.node.delta!.whereType<TextInsert>();
    TextSpan textSpan = getTextSpan(textInserts: textInserts);
    return RichText(
      key: textKey,
      textAlign: widget.textAlign ?? TextAlign.start,
      textHeightBehavior: TextHeightBehavior(
        applyHeightToFirstAscent:
            textStyleConfiguration.applyHeightToFirstAscent,
        applyHeightToLastDescent:
            textStyleConfiguration.applyHeightToLastDescent,
      ),
      text: widget.textSpanDecorator != null
          ? widget.textSpanDecorator!(textSpan)
          : textSpan,
      textDirection: textDirection(),
      textScaler:
          TextScaler.linear(widget.editorState.editorStyle.textScaleFactor),
    );
  }

  Widget _buildAutoCompleteRichText() {
    final textInserts = widget.node.delta!.whereType<TextInsert>();
    TextSpan textSpan = getTextSpan(textInserts: textInserts);
    return ValueListenableBuilder(
      valueListenable: widget.editorState.selectionNotifier,
      builder: (_, __, ___) {
        final autoCompleteText = autoCompleteTextProvider?.call(
          context,
          widget.node,
          textSpan,
        );
        if (autoCompleteText == null || autoCompleteText.isEmpty) {
          return const SizedBox.shrink();
        }
        textSpan = getTextSpan(
          textInserts: [
            ...textInserts.map(
              (e) => TextInsert(
                e.text,
                attributes: {
                  AppFlowyRichTextKeys.transparent: true,
                },
              ),
            ),
            TextInsert(
              autoCompleteText,
              attributes: {
                AppFlowyRichTextKeys.autoComplete: true,
              },
            ),
          ],
        );
        return RichText(
          textAlign: widget.textAlign ?? TextAlign.start,
          textHeightBehavior: TextHeightBehavior(
            applyHeightToFirstAscent:
                textStyleConfiguration.applyHeightToFirstAscent,
            applyHeightToLastDescent:
                textStyleConfiguration.applyHeightToLastDescent,
          ),
          text: widget.textSpanDecorator != null
              ? widget.textSpanDecorator!(textSpan)
              : textSpan,
          textDirection: textDirection(),
          textScaler:
              TextScaler.linear(widget.editorState.editorStyle.textScaleFactor),
        );
      },
    );
  }

  TextSpan getPlaceholderTextSpan() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.placeholderText,
          style: textStyleConfiguration.text.copyWith(
            height: widget.lineHeight,
          ),
        ),
      ],
    );
  }

  TextSpan getTextSpan({
    required Iterable<TextInsert> textInserts,
  }) {
    int offset = 0;
    List<InlineSpan> textSpans = [];
    for (final textInsert in textInserts) {
      TextStyle textStyle =
          textStyleConfiguration.text.copyWith(height: widget.lineHeight);
      final attributes = textInsert.attributes;
      if (attributes != null) {
        if (attributes.bold == true) {
          textStyle = textStyle.combine(textStyleConfiguration.bold);
        }
        if (attributes.italic == true) {
          textStyle = textStyle.combine(textStyleConfiguration.italic);
        }
        if (attributes.underline == true) {
          textStyle = textStyle.combine(textStyleConfiguration.underline);
        }
        if (attributes.strikethrough == true) {
          textStyle = textStyle.combine(textStyleConfiguration.strikethrough);
        }
        if (attributes.href != null) {
          textStyle = textStyle.combine(textStyleConfiguration.href);
        }
        if (attributes.code == true) {
          textStyle = textStyle.combine(textStyleConfiguration.code);
        }
        if (attributes.backgroundColor != null) {
          textStyle = textStyle.combine(
            TextStyle(backgroundColor: attributes.backgroundColor),
          );
        }
        if (attributes.findBackgroundColor != null) {
          textStyle = textStyle.combine(
            TextStyle(backgroundColor: attributes.findBackgroundColor),
          );
        }
        if (attributes.color != null) {
          textStyle = textStyle.combine(
            TextStyle(color: attributes.color),
          );
        }
        if (attributes.fontFamily != null) {
          textStyle = textStyle.combine(
            TextStyle(fontFamily: attributes.fontFamily),
          );
        }
        if (attributes.fontSize != null) {
          textStyle = textStyle.combine(
            TextStyle(fontSize: attributes.fontSize),
          );
        }
        if (attributes.autoComplete == true) {
          textStyle = textStyle.combine(textStyleConfiguration.autoComplete);
        }
        if (attributes.transparent == true) {
          textStyle = textStyle.combine(
            const TextStyle(color: Colors.transparent),
          );
        }
      }
      final textSpan = TextSpan(
        text: textInsert.text,
        style: textStyle,
      );
      textSpans.add(
        textSpanDecoratorForAttribute != null
            ? textSpanDecoratorForAttribute!(
                context,
                widget.node,
                offset,
                textInsert,
                textSpan,
                widget.textSpanDecorator?.call(textSpan) ?? textSpan,
              )
            : textSpan,
      );
      offset += textInsert.length;
    }
    return TextSpan(
      children: textSpans,
    );
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

extension AppFlowyRichTextAttributes on Attributes {
  bool get bold => this[AppFlowyRichTextKeys.bold] == true;

  bool get italic => this[AppFlowyRichTextKeys.italic] == true;

  bool get underline => this[AppFlowyRichTextKeys.underline] == true;

  bool get code => this[AppFlowyRichTextKeys.code] == true;

  bool get strikethrough {
    return (containsKey(AppFlowyRichTextKeys.strikethrough) &&
        this[AppFlowyRichTextKeys.strikethrough] == true);
  }

  Color? get color {
    final textColor = this[AppFlowyRichTextKeys.textColor] as String?;
    return textColor?.tryToColor();
  }

  Color? get backgroundColor {
    final highlightColor =
        this[AppFlowyRichTextKeys.backgroundColor] as String?;
    return highlightColor?.tryToColor();
  }

  Color? get findBackgroundColor {
    final findBackgroundColor =
        this[AppFlowyRichTextKeys.findBackgroundColor] as String?;
    return findBackgroundColor?.tryToColor();
  }

  String? get href {
    if (this[AppFlowyRichTextKeys.href] is String) {
      return this[AppFlowyRichTextKeys.href];
    }
    return null;
  }

  String? get fontFamily {
    if (this[AppFlowyRichTextKeys.fontFamily] is String) {
      return this[AppFlowyRichTextKeys.fontFamily];
    }
    return null;
  }

  double? get fontSize {
    if (this[AppFlowyRichTextKeys.fontSize] is double) {
      return this[AppFlowyRichTextKeys.fontSize];
    }
    return null;
  }

  bool get autoComplete => this[AppFlowyRichTextKeys.autoComplete] == true;

  bool get transparent => this[AppFlowyRichTextKeys.transparent] == true;
}
