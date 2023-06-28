import 'package:appflowy_editor/appflowy_editor.dart';

import 'package:flutter/material.dart';

class EditorStyle extends ThemeExtension<EditorStyle> {
  // Editor styles
  final EdgeInsets? padding;

  final Color cursorColor;
  final Color selectionColor;
  final TextStyleConfiguration textStyleConfiguration;
  final TextSpanDecoratorForCustomAttributes? textSpanDecorator;

  // @Deprecated('customize the editor\'s background color directly')
  final Color? backgroundColor;

  // Text styles
  @Deprecated('customize the block component directly')
  final EdgeInsets? textPadding;
  @Deprecated('customize the block component directly')
  final TextStyle? textStyle;
  @Deprecated('customize the block component directly')
  final TextStyle? placeholderTextStyle;
  @Deprecated('customize the block component directly')
  final double lineHeight;

  // Rich text styles
  @Deprecated('customize the text style configuration directly')
  final TextStyle? bold;
  @Deprecated('customize the text style configuration directly')
  final TextStyle? italic;
  @Deprecated('customize the text style configuration directly')
  final TextStyle? underline;
  @Deprecated('customize the text style configuration directly')
  final TextStyle? strikethrough;
  @Deprecated('customize the text style configuration directly')
  final TextStyle? href;
  @Deprecated('customize the text style configuration directly')
  final TextStyle? code;
  @Deprecated('customize the text style configuration directly')
  final String? highlightColorHex;

  // Selection menu styles
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuBackgroundColor;
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuItemTextColor;
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuItemIconColor;
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuItemSelectedTextColor;
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuItemSelectedIconColor;
  @Deprecated('customize the selection menu directly')
  final Color? selectionMenuItemSelectedColor;
  @Deprecated('customize the selection menu directly')
  final Color? toolbarColor;
  @Deprecated('customize the selection menu directly')
  final double toolbarElevation;

  // Item's pop up menu styles
  final Color? popupMenuFGColor;
  final Color? popupMenuHoverColor;

  const EditorStyle({
    required this.padding,
    required this.cursorColor,
    required this.selectionColor,
    required this.textStyleConfiguration,
    required this.backgroundColor,
    required this.selectionMenuBackgroundColor,
    required this.selectionMenuItemTextColor,
    required this.selectionMenuItemIconColor,
    required this.selectionMenuItemSelectedTextColor,
    required this.selectionMenuItemSelectedIconColor,
    required this.selectionMenuItemSelectedColor,
    required this.toolbarColor,
    required this.toolbarElevation,
    required this.textPadding,
    required this.textStyle,
    required this.placeholderTextStyle,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.strikethrough,
    required this.href,
    required this.code,
    required this.highlightColorHex,
    required this.lineHeight,
    required this.popupMenuFGColor,
    required this.popupMenuHoverColor,
    required this.textSpanDecorator,
  });

  const EditorStyle.desktop({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForCustomAttributes? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 100),
          backgroundColor: backgroundColor ?? Colors.white,
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor:
              selectionColor ?? const Color.fromARGB(53, 111, 201, 231),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator: textSpanDecorator,
          selectionMenuBackgroundColor: null,
          selectionMenuItemTextColor: null,
          selectionMenuItemIconColor: null,
          selectionMenuItemSelectedTextColor: null,
          selectionMenuItemSelectedIconColor: null,
          selectionMenuItemSelectedColor: null,
          toolbarColor: null,
          toolbarElevation: 0,
          textPadding: null,
          textStyle: null,
          placeholderTextStyle: null,
          bold: null,
          italic: null,
          underline: null,
          strikethrough: null,
          href: null,
          code: null,
          highlightColorHex: null,
          lineHeight: 0,
          popupMenuFGColor: null,
          popupMenuHoverColor: null,
        );

  const EditorStyle.mobile({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForCustomAttributes? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: backgroundColor ?? Colors.white,
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor:
              selectionColor ?? const Color.fromARGB(53, 111, 201, 231),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator: textSpanDecorator,
          selectionMenuBackgroundColor: null,
          selectionMenuItemTextColor: null,
          selectionMenuItemIconColor: null,
          selectionMenuItemSelectedTextColor: null,
          selectionMenuItemSelectedIconColor: null,
          selectionMenuItemSelectedColor: null,
          toolbarColor: null,
          toolbarElevation: 0,
          textPadding: null,
          textStyle: null,
          placeholderTextStyle: null,
          bold: null,
          italic: null,
          underline: null,
          strikethrough: null,
          href: null,
          code: null,
          highlightColorHex: null,
          lineHeight: 0,
          popupMenuFGColor: null,
          popupMenuHoverColor: null,
        );

  @override
  EditorStyle copyWith({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForCustomAttributes? textSpanDecorator,
    Color? selectionMenuBackgroundColor,
    Color? selectionMenuItemTextColor,
    Color? selectionMenuItemIconColor,
    Color? selectionMenuItemSelectedTextColor,
    Color? selectionMenuItemSelectedIconColor,
    Color? selectionMenuItemSelectedColor,
    Color? toolbarColor,
    double? toolbarElevation,
    TextStyle? textStyle,
    TextStyle? placeholderTextStyle,
    TextStyle? bold,
    TextStyle? italic,
    TextStyle? underline,
    TextStyle? strikethrough,
    TextStyle? href,
    TextStyle? code,
    String? highlightColorHex,
    double? lineHeight,
    Color? popupMenuFGColor,
    Color? popupMenuHoverColor,
    EdgeInsets? textPadding,
  }) {
    return EditorStyle(
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyleConfiguration:
          textStyleConfiguration ?? this.textStyleConfiguration,
      textSpanDecorator: textSpanDecorator ?? this.textSpanDecorator,
      selectionMenuBackgroundColor:
          selectionMenuBackgroundColor ?? this.selectionMenuBackgroundColor,
      selectionMenuItemTextColor:
          selectionMenuItemTextColor ?? this.selectionMenuItemTextColor,
      selectionMenuItemIconColor:
          selectionMenuItemIconColor ?? this.selectionMenuItemIconColor,
      selectionMenuItemSelectedTextColor: selectionMenuItemSelectedTextColor ??
          this.selectionMenuItemSelectedTextColor,
      selectionMenuItemSelectedIconColor: selectionMenuItemSelectedIconColor ??
          this.selectionMenuItemSelectedIconColor,
      selectionMenuItemSelectedColor:
          selectionMenuItemSelectedColor ?? this.selectionMenuItemSelectedColor,
      toolbarColor: toolbarColor ?? this.toolbarColor,
      toolbarElevation: toolbarElevation ?? this.toolbarElevation,
      textPadding: textPadding ?? this.textPadding,
      textStyle: textStyle ?? this.textStyle,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      href: href ?? this.href,
      code: code ?? this.code,
      highlightColorHex: highlightColorHex ?? this.highlightColorHex,
      lineHeight: lineHeight ?? this.lineHeight,
      popupMenuFGColor: popupMenuFGColor ?? this.popupMenuFGColor,
      popupMenuHoverColor: popupMenuHoverColor ?? this.popupMenuHoverColor,
    );
  }

  @override
  ThemeExtension<EditorStyle> lerp(
    ThemeExtension<EditorStyle>? other,
    double t,
  ) {
    if (other == null || other is! EditorStyle) {
      return this;
    }
    return EditorStyle(
      padding: EdgeInsets.lerp(padding, other.padding, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t)!,
      textPadding: EdgeInsets.lerp(textPadding, other.textPadding, t),
      textStyleConfiguration: other.textStyleConfiguration,
      textSpanDecorator: other.textSpanDecorator,
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t)!,
      selectionMenuBackgroundColor: Color.lerp(
        selectionMenuBackgroundColor,
        other.selectionMenuBackgroundColor,
        t,
      ),
      selectionMenuItemTextColor: Color.lerp(
        selectionMenuItemTextColor,
        other.selectionMenuItemTextColor,
        t,
      ),
      selectionMenuItemIconColor: Color.lerp(
        selectionMenuItemIconColor,
        other.selectionMenuItemIconColor,
        t,
      ),
      selectionMenuItemSelectedTextColor: Color.lerp(
        selectionMenuItemSelectedTextColor,
        other.selectionMenuItemSelectedTextColor,
        t,
      ),
      selectionMenuItemSelectedIconColor: Color.lerp(
        selectionMenuItemSelectedIconColor,
        other.selectionMenuItemSelectedIconColor,
        t,
      ),
      selectionMenuItemSelectedColor: Color.lerp(
        selectionMenuItemSelectedColor,
        other.selectionMenuItemSelectedColor,
        t,
      ),
      toolbarColor: Color.lerp(toolbarColor, other.toolbarColor, t),
      toolbarElevation: toolbarElevation,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      placeholderTextStyle:
          TextStyle.lerp(placeholderTextStyle, other.placeholderTextStyle, t),
      bold: TextStyle.lerp(bold, other.bold, t),
      italic: TextStyle.lerp(italic, other.italic, t),
      underline: TextStyle.lerp(underline, other.underline, t),
      strikethrough: TextStyle.lerp(strikethrough, other.strikethrough, t),
      href: TextStyle.lerp(href, other.href, t),
      code: TextStyle.lerp(code, other.code, t),
      highlightColorHex: highlightColorHex,
      lineHeight: lineHeight,
      popupMenuFGColor: Color.lerp(popupMenuFGColor, other.popupMenuFGColor, t),
      popupMenuHoverColor:
          Color.lerp(popupMenuHoverColor, other.popupMenuHoverColor, t),
    );
  }

  static EditorStyle? of(BuildContext context) {
    return Theme.of(context).extension<EditorStyle>();
  }
}
