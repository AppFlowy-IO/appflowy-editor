// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppFlowyEditorLocalizations {
  AppFlowyEditorLocalizations();

  static AppFlowyEditorLocalizations? _current;

  static AppFlowyEditorLocalizations get current {
    assert(_current != null,
        'No instance of AppFlowyEditorLocalizations was loaded. Try to initialize the AppFlowyEditorLocalizations delegate before accessing AppFlowyEditorLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppFlowyEditorLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppFlowyEditorLocalizations();
      AppFlowyEditorLocalizations._current = instance;

      return instance;
    });
  }

  static AppFlowyEditorLocalizations of(BuildContext context) {
    final instance = AppFlowyEditorLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppFlowyEditorLocalizations present in the widget tree. Did you add AppFlowyEditorLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppFlowyEditorLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppFlowyEditorLocalizations>(
        context, AppFlowyEditorLocalizations);
  }

  /// `Bold`
  String get bold {
    return Intl.message(
      'Bold',
      name: 'bold',
      desc: '',
      args: [],
    );
  }

  /// `Bulleted List`
  String get bulletedList {
    return Intl.message(
      'Bulleted List',
      name: 'bulletedList',
      desc: '',
      args: [],
    );
  }

  /// `Checkbox`
  String get checkbox {
    return Intl.message(
      'Checkbox',
      name: 'checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Embed Code`
  String get embedCode {
    return Intl.message(
      'Embed Code',
      name: 'embedCode',
      desc: '',
      args: [],
    );
  }

  /// `H1`
  String get heading1 {
    return Intl.message(
      'H1',
      name: 'heading1',
      desc: '',
      args: [],
    );
  }

  /// `H2`
  String get heading2 {
    return Intl.message(
      'H2',
      name: 'heading2',
      desc: '',
      args: [],
    );
  }

  /// `H3`
  String get heading3 {
    return Intl.message(
      'H3',
      name: 'heading3',
      desc: '',
      args: [],
    );
  }

  /// `Highlight`
  String get highlight {
    return Intl.message(
      'Highlight',
      name: 'highlight',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Italic`
  String get italic {
    return Intl.message(
      'Italic',
      name: 'italic',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get link {
    return Intl.message(
      'Link',
      name: 'link',
      desc: '',
      args: [],
    );
  }

  /// `Numbered List`
  String get numberedList {
    return Intl.message(
      'Numbered List',
      name: 'numberedList',
      desc: '',
      args: [],
    );
  }

  /// `Quote`
  String get quote {
    return Intl.message(
      'Quote',
      name: 'quote',
      desc: '',
      args: [],
    );
  }

  /// `Strikethrough`
  String get strikethrough {
    return Intl.message(
      'Strikethrough',
      name: 'strikethrough',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message(
      'Text',
      name: 'text',
      desc: '',
      args: [],
    );
  }

  /// `Underline`
  String get underline {
    return Intl.message(
      'Underline',
      name: 'underline',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get fontColorDefault {
    return Intl.message(
      'Default',
      name: 'fontColorDefault',
      desc: '',
      args: [],
    );
  }

  /// `Gray`
  String get fontColorGray {
    return Intl.message(
      'Gray',
      name: 'fontColorGray',
      desc: '',
      args: [],
    );
  }

  /// `Brown`
  String get fontColorBrown {
    return Intl.message(
      'Brown',
      name: 'fontColorBrown',
      desc: '',
      args: [],
    );
  }

  /// `Orange`
  String get fontColorOrange {
    return Intl.message(
      'Orange',
      name: 'fontColorOrange',
      desc: '',
      args: [],
    );
  }

  /// `Yellow`
  String get fontColorYellow {
    return Intl.message(
      'Yellow',
      name: 'fontColorYellow',
      desc: '',
      args: [],
    );
  }

  /// `Green`
  String get fontColorGreen {
    return Intl.message(
      'Green',
      name: 'fontColorGreen',
      desc: '',
      args: [],
    );
  }

  /// `Blue`
  String get fontColorBlue {
    return Intl.message(
      'Blue',
      name: 'fontColorBlue',
      desc: '',
      args: [],
    );
  }

  /// `Purple`
  String get fontColorPurple {
    return Intl.message(
      'Purple',
      name: 'fontColorPurple',
      desc: '',
      args: [],
    );
  }

  /// `Pink`
  String get fontColorPink {
    return Intl.message(
      'Pink',
      name: 'fontColorPink',
      desc: '',
      args: [],
    );
  }

  /// `Red`
  String get fontColorRed {
    return Intl.message(
      'Red',
      name: 'fontColorRed',
      desc: '',
      args: [],
    );
  }

  /// `Default background`
  String get backgroundColorDefault {
    return Intl.message(
      'Default background',
      name: 'backgroundColorDefault',
      desc: '',
      args: [],
    );
  }

  /// `Gray background`
  String get backgroundColorGray {
    return Intl.message(
      'Gray background',
      name: 'backgroundColorGray',
      desc: '',
      args: [],
    );
  }

  /// `Brown background`
  String get backgroundColorBrown {
    return Intl.message(
      'Brown background',
      name: 'backgroundColorBrown',
      desc: '',
      args: [],
    );
  }

  /// `Orange background`
  String get backgroundColorOrange {
    return Intl.message(
      'Orange background',
      name: 'backgroundColorOrange',
      desc: '',
      args: [],
    );
  }

  /// `Yellow background`
  String get backgroundColorYellow {
    return Intl.message(
      'Yellow background',
      name: 'backgroundColorYellow',
      desc: '',
      args: [],
    );
  }

  /// `Green background`
  String get backgroundColorGreen {
    return Intl.message(
      'Green background',
      name: 'backgroundColorGreen',
      desc: '',
      args: [],
    );
  }

  /// `Blue background`
  String get backgroundColorBlue {
    return Intl.message(
      'Blue background',
      name: 'backgroundColorBlue',
      desc: '',
      args: [],
    );
  }

  /// `Purple background`
  String get backgroundColorPurple {
    return Intl.message(
      'Purple background',
      name: 'backgroundColorPurple',
      desc: '',
      args: [],
    );
  }

  /// `Pink background`
  String get backgroundColorPink {
    return Intl.message(
      'Pink background',
      name: 'backgroundColorPink',
      desc: '',
      args: [],
    );
  }

  /// `Red background`
  String get backgroundColorRed {
    return Intl.message(
      'Red background',
      name: 'backgroundColorRed',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Tint 1`
  String get tint1 {
    return Intl.message(
      'Tint 1',
      name: 'tint1',
      desc: '',
      args: [],
    );
  }

  /// `Tint 2`
  String get tint2 {
    return Intl.message(
      'Tint 2',
      name: 'tint2',
      desc: '',
      args: [],
    );
  }

  /// `Tint 3`
  String get tint3 {
    return Intl.message(
      'Tint 3',
      name: 'tint3',
      desc: '',
      args: [],
    );
  }

  /// `Tint 4`
  String get tint4 {
    return Intl.message(
      'Tint 4',
      name: 'tint4',
      desc: '',
      args: [],
    );
  }

  /// `Tint 5`
  String get tint5 {
    return Intl.message(
      'Tint 5',
      name: 'tint5',
      desc: '',
      args: [],
    );
  }

  /// `Tint 6`
  String get tint6 {
    return Intl.message(
      'Tint 6',
      name: 'tint6',
      desc: '',
      args: [],
    );
  }

  /// `Tint 7`
  String get tint7 {
    return Intl.message(
      'Tint 7',
      name: 'tint7',
      desc: '',
      args: [],
    );
  }

  /// `Tint 8`
  String get tint8 {
    return Intl.message(
      'Tint 8',
      name: 'tint8',
      desc: '',
      args: [],
    );
  }

  /// `Tint 9`
  String get tint9 {
    return Intl.message(
      'Tint 9',
      name: 'tint9',
      desc: '',
      args: [],
    );
  }

  /// `Purple`
  String get lightLightTint1 {
    return Intl.message(
      'Purple',
      name: 'lightLightTint1',
      desc: '',
      args: [],
    );
  }

  /// `Pink`
  String get lightLightTint2 {
    return Intl.message(
      'Pink',
      name: 'lightLightTint2',
      desc: '',
      args: [],
    );
  }

  /// `Light Pink`
  String get lightLightTint3 {
    return Intl.message(
      'Light Pink',
      name: 'lightLightTint3',
      desc: '',
      args: [],
    );
  }

  /// `Orange`
  String get lightLightTint4 {
    return Intl.message(
      'Orange',
      name: 'lightLightTint4',
      desc: '',
      args: [],
    );
  }

  /// `Yellow`
  String get lightLightTint5 {
    return Intl.message(
      'Yellow',
      name: 'lightLightTint5',
      desc: '',
      args: [],
    );
  }

  /// `Lime`
  String get lightLightTint6 {
    return Intl.message(
      'Lime',
      name: 'lightLightTint6',
      desc: '',
      args: [],
    );
  }

  /// `Green`
  String get lightLightTint7 {
    return Intl.message(
      'Green',
      name: 'lightLightTint7',
      desc: '',
      args: [],
    );
  }

  /// `Aqua`
  String get lightLightTint8 {
    return Intl.message(
      'Aqua',
      name: 'lightLightTint8',
      desc: '',
      args: [],
    );
  }

  /// `Blue`
  String get lightLightTint9 {
    return Intl.message(
      'Blue',
      name: 'lightLightTint9',
      desc: '',
      args: [],
    );
  }

  /// `List item`
  String get listItemPlaceholder {
    return Intl.message(
      'List item',
      name: 'listItemPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `To-do`
  String get toDoPlaceholder {
    return Intl.message(
      'To-do',
      name: 'toDoPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get urlHint {
    return Intl.message(
      'URL',
      name: 'urlHint',
      desc: '',
      args: [],
    );
  }

  /// `Heading 1`
  String get mobileHeading1 {
    return Intl.message(
      'Heading 1',
      name: 'mobileHeading1',
      desc: '',
      args: [],
    );
  }

  /// `Heading 2`
  String get mobileHeading2 {
    return Intl.message(
      'Heading 2',
      name: 'mobileHeading2',
      desc: '',
      args: [],
    );
  }

  /// `Heading 3`
  String get mobileHeading3 {
    return Intl.message(
      'Heading 3',
      name: 'mobileHeading3',
      desc: '',
      args: [],
    );
  }

  /// `Text Color`
  String get textColor {
    return Intl.message(
      'Text Color',
      name: 'textColor',
      desc: '',
      args: [],
    );
  }

  /// `Background Color`
  String get backgroundColor {
    return Intl.message(
      'Background Color',
      name: 'backgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `Add your link`
  String get addYourLink {
    return Intl.message(
      'Add your link',
      name: 'addYourLink',
      desc: '',
      args: [],
    );
  }

  /// `Open link`
  String get openLink {
    return Intl.message(
      'Open link',
      name: 'openLink',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message(
      'Copy link',
      name: 'copyLink',
      desc: '',
      args: [],
    );
  }

  /// `Remove link`
  String get removeLink {
    return Intl.message(
      'Remove link',
      name: 'removeLink',
      desc: '',
      args: [],
    );
  }

  /// `Edit link`
  String get editLink {
    return Intl.message(
      'Edit link',
      name: 'editLink',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get linkText {
    return Intl.message(
      'Text',
      name: 'linkText',
      desc: '',
      args: [],
    );
  }

  /// `Please enter text`
  String get linkTextHint {
    return Intl.message(
      'Please enter text',
      name: 'linkTextHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter URL`
  String get linkAddressHint {
    return Intl.message(
      'Please enter URL',
      name: 'linkAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `Highlight Color`
  String get highlightColor {
    return Intl.message(
      'Highlight Color',
      name: 'highlightColor',
      desc: '',
      args: [],
    );
  }

  /// `Clear highlight color`
  String get clearHighlightColor {
    return Intl.message(
      'Clear highlight color',
      name: 'clearHighlightColor',
      desc: '',
      args: [],
    );
  }

  /// `Custom color`
  String get customColor {
    return Intl.message(
      'Custom color',
      name: 'customColor',
      desc: '',
      args: [],
    );
  }

  /// `Hex value`
  String get hexValue {
    return Intl.message(
      'Hex value',
      name: 'hexValue',
      desc: '',
      args: [],
    );
  }

  /// `Opacity`
  String get opacity {
    return Intl.message(
      'Opacity',
      name: 'opacity',
      desc: '',
      args: [],
    );
  }

  /// `Reset to default color`
  String get resetToDefaultColor {
    return Intl.message(
      'Reset to default color',
      name: 'resetToDefaultColor',
      desc: '',
      args: [],
    );
  }

  /// `LTR`
  String get ltr {
    return Intl.message(
      'LTR',
      name: 'ltr',
      desc: '',
      args: [],
    );
  }

  /// `RTL`
  String get rtl {
    return Intl.message(
      'RTL',
      name: 'rtl',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Cut`
  String get cut {
    return Intl.message(
      'Cut',
      name: 'cut',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message(
      'Paste',
      name: 'paste',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get find {
    return Intl.message(
      'Find',
      name: 'find',
      desc: '',
      args: [],
    );
  }

  /// `Previous match`
  String get previousMatch {
    return Intl.message(
      'Previous match',
      name: 'previousMatch',
      desc: '',
      args: [],
    );
  }

  /// `Next match`
  String get nextMatch {
    return Intl.message(
      'Next match',
      name: 'nextMatch',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeFind {
    return Intl.message(
      'Close',
      name: 'closeFind',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message(
      'Replace',
      name: 'replace',
      desc: '',
      args: [],
    );
  }

  /// `Replace all`
  String get replaceAll {
    return Intl.message(
      'Replace all',
      name: 'replaceAll',
      desc: '',
      args: [],
    );
  }

  /// `Regex`
  String get regex {
    return Intl.message(
      'Regex',
      name: 'regex',
      desc: '',
      args: [],
    );
  }

  /// `Case sensitive`
  String get caseSensitive {
    return Intl.message(
      'Case sensitive',
      name: 'caseSensitive',
      desc: '',
      args: [],
    );
  }

  /// `Regex Error`
  String get regexError {
    return Intl.message(
      'Regex Error',
      name: 'regexError',
      desc: '',
      args: [],
    );
  }

  /// `No result`
  String get noFindResult {
    return Intl.message(
      'No result',
      name: 'noFindResult',
      desc: '',
      args: [],
    );
  }

  /// `Enter a pattern`
  String get emptySearchBoxHint {
    return Intl.message(
      'Enter a pattern',
      name: 'emptySearchBoxHint',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get uploadImage {
    return Intl.message(
      'Upload',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get urlImage {
    return Intl.message(
      'URL',
      name: 'urlImage',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect Link`
  String get incorrectLink {
    return Intl.message(
      'Incorrect Link',
      name: 'incorrectLink',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Choose an image`
  String get chooseImage {
    return Intl.message(
      'Choose an image',
      name: 'chooseImage',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Could not load the image`
  String get imageLoadFailed {
    return Intl.message(
      'Could not load the image',
      name: 'imageLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Divider`
  String get divider {
    return Intl.message(
      'Divider',
      name: 'divider',
      desc: '',
      args: [],
    );
  }

  /// `Table`
  String get table {
    return Intl.message(
      'Table',
      name: 'table',
      desc: '',
      args: [],
    );
  }

  /// `Add before`
  String get colAddBefore {
    return Intl.message(
      'Add before',
      name: 'colAddBefore',
      desc: '',
      args: [],
    );
  }

  /// `Add before`
  String get rowAddBefore {
    return Intl.message(
      'Add before',
      name: 'rowAddBefore',
      desc: '',
      args: [],
    );
  }

  /// `Add after`
  String get colAddAfter {
    return Intl.message(
      'Add after',
      name: 'colAddAfter',
      desc: '',
      args: [],
    );
  }

  /// `Add after`
  String get rowAddAfter {
    return Intl.message(
      'Add after',
      name: 'rowAddAfter',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get colRemove {
    return Intl.message(
      'Remove',
      name: 'colRemove',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get rowRemove {
    return Intl.message(
      'Remove',
      name: 'rowRemove',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get colDuplicate {
    return Intl.message(
      'Duplicate',
      name: 'colDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get rowDuplicate {
    return Intl.message(
      'Duplicate',
      name: 'rowDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Clear Content`
  String get colClear {
    return Intl.message(
      'Clear Content',
      name: 'colClear',
      desc: '',
      args: [],
    );
  }

  /// `Clear Content`
  String get rowClear {
    return Intl.message(
      'Clear Content',
      name: 'rowClear',
      desc: '',
      args: [],
    );
  }

  /// `Enter a / to insert a block, or start typing`
  String get slashPlaceHolder {
    return Intl.message(
      'Enter a / to insert a block, or start typing',
      name: 'slashPlaceHolder',
      desc: '',
      args: [],
    );
  }

  /// `Align Left`
  String get textAlignLeft {
    return Intl.message(
      'Align Left',
      name: 'textAlignLeft',
      desc: '',
      args: [],
    );
  }

  /// `Align Center`
  String get textAlignCenter {
    return Intl.message(
      'Align Center',
      name: 'textAlignCenter',
      desc: '',
      args: [],
    );
  }

  /// `Align Right`
  String get textAlignRight {
    return Intl.message(
      'Align Right',
      name: 'textAlignRight',
      desc: '',
      args: [],
    );
  }

  /// `Convert to link`
  String get cmdConvertToLink {
    return Intl.message(
      'Convert to link',
      name: 'cmdConvertToLink',
      desc: '',
      args: [],
    );
  }

  /// `convert to paragraph`
  String get cmdConvertToParagraph {
    return Intl.message(
      'convert to paragraph',
      name: 'cmdConvertToParagraph',
      desc: '',
      args: [],
    );
  }

  /// `Copy selection`
  String get cmdCopySelection {
    return Intl.message(
      'Copy selection',
      name: 'cmdCopySelection',
      desc: '',
      args: [],
    );
  }

  /// `Cut selection`
  String get cmdCutSelection {
    return Intl.message(
      'Cut selection',
      name: 'cmdCutSelection',
      desc: '',
      args: [],
    );
  }

  /// `Delete character to the left`
  String get cmdDeleteLeft {
    return Intl.message(
      'Delete character to the left',
      name: 'cmdDeleteLeft',
      desc: '',
      args: [],
    );
  }

  /// `Delete to beginning of line`
  String get cmdDeleteLineLeft {
    return Intl.message(
      'Delete to beginning of line',
      name: 'cmdDeleteLineLeft',
      desc: '',
      args: [],
    );
  }

  /// `Delete character to the right`
  String get cmdDeleteRight {
    return Intl.message(
      'Delete character to the right',
      name: 'cmdDeleteRight',
      desc: '',
      args: [],
    );
  }

  /// `delete word at left`
  String get cmdDeleteWordLeft {
    return Intl.message(
      'delete word at left',
      name: 'cmdDeleteWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `delete word at right`
  String get cmdDeleteWordRight {
    return Intl.message(
      'delete word at right',
      name: 'cmdDeleteWordRight',
      desc: '',
      args: [],
    );
  }

  /// `exit editing mode`
  String get cmdExitEditing {
    return Intl.message(
      'exit editing mode',
      name: 'cmdExitEditing',
      desc: '',
      args: [],
    );
  }

  /// `indent`
  String get cmdIndent {
    return Intl.message(
      'indent',
      name: 'cmdIndent',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to the bottom`
  String get cmdMoveCursorBottom {
    return Intl.message(
      'move cursor to the bottom',
      name: 'cmdMoveCursorBottom',
      desc: '',
      args: [],
    );
  }

  /// `Select all until end of file`
  String get cmdMoveCursorBottomSelect {
    return Intl.message(
      'Select all until end of file',
      name: 'cmdMoveCursorBottomSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor down`
  String get cmdMoveCursorDown {
    return Intl.message(
      'move cursor down',
      name: 'cmdMoveCursorDown',
      desc: '',
      args: [],
    );
  }

  /// `Select downward`
  String get cmdMoveCursorDownSelect {
    return Intl.message(
      'Select downward',
      name: 'cmdMoveCursorDownSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor left`
  String get cmdMoveCursorLeft {
    return Intl.message(
      'move cursor left',
      name: 'cmdMoveCursorLeft',
      desc: '',
      args: [],
    );
  }

  /// `Select left`
  String get cmdMoveCursorLeftSelect {
    return Intl.message(
      'Select left',
      name: 'cmdMoveCursorLeftSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to the end of line`
  String get cmdMoveCursorLineEnd {
    return Intl.message(
      'move cursor to the end of line',
      name: 'cmdMoveCursorLineEnd',
      desc: '',
      args: [],
    );
  }

  /// `Select to end of line`
  String get cmdMoveCursorLineEndSelect {
    return Intl.message(
      'Select to end of line',
      name: 'cmdMoveCursorLineEndSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to start of line`
  String get cmdMoveCursorLineStart {
    return Intl.message(
      'move cursor to start of line',
      name: 'cmdMoveCursorLineStart',
      desc: '',
      args: [],
    );
  }

  /// `Select to start of line`
  String get cmdMoveCursorLineStartSelect {
    return Intl.message(
      'Select to start of line',
      name: 'cmdMoveCursorLineStartSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor right`
  String get cmdMoveCursorRight {
    return Intl.message(
      'move cursor right',
      name: 'cmdMoveCursorRight',
      desc: '',
      args: [],
    );
  }

  /// `Select right`
  String get cmdMoveCursorRightSelect {
    return Intl.message(
      'Select right',
      name: 'cmdMoveCursorRightSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to the top`
  String get cmdMoveCursorTop {
    return Intl.message(
      'move cursor to the top',
      name: 'cmdMoveCursorTop',
      desc: '',
      args: [],
    );
  }

  /// `Select all until start of file`
  String get cmdMoveCursorTopSelect {
    return Intl.message(
      'Select all until start of file',
      name: 'cmdMoveCursorTopSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor up`
  String get cmdMoveCursorUp {
    return Intl.message(
      'move cursor up',
      name: 'cmdMoveCursorUp',
      desc: '',
      args: [],
    );
  }

  /// `Select upward`
  String get cmdMoveCursorUpSelect {
    return Intl.message(
      'Select upward',
      name: 'cmdMoveCursorUpSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to word on the left`
  String get cmdMoveCursorWordLeft {
    return Intl.message(
      'move cursor to word on the left',
      name: 'cmdMoveCursorWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `Select word to the left`
  String get cmdMoveCursorWordLeftSelect {
    return Intl.message(
      'Select word to the left',
      name: 'cmdMoveCursorWordLeftSelect',
      desc: '',
      args: [],
    );
  }

  /// `move cursor to word on the right`
  String get cmdMoveCursorWordRight {
    return Intl.message(
      'move cursor to word on the right',
      name: 'cmdMoveCursorWordRight',
      desc: '',
      args: [],
    );
  }

  /// `Select word to the right`
  String get cmdMoveCursorWordRightSelect {
    return Intl.message(
      'Select word to the right',
      name: 'cmdMoveCursorWordRightSelect',
      desc: '',
      args: [],
    );
  }

  /// `Open Find`
  String get cmdOpenFind {
    return Intl.message(
      'Open Find',
      name: 'cmdOpenFind',
      desc: '',
      args: [],
    );
  }

  /// `Open Find and Replace`
  String get cmdOpenFindAndReplace {
    return Intl.message(
      'Open Find and Replace',
      name: 'cmdOpenFindAndReplace',
      desc: '',
      args: [],
    );
  }

  /// `open link`
  String get cmdOpenLink {
    return Intl.message(
      'open link',
      name: 'cmdOpenLink',
      desc: '',
      args: [],
    );
  }

  /// `open links`
  String get cmdOpenLinks {
    return Intl.message(
      'open links',
      name: 'cmdOpenLinks',
      desc: '',
      args: [],
    );
  }

  /// `outdent`
  String get cmdOutdent {
    return Intl.message(
      'outdent',
      name: 'cmdOutdent',
      desc: '',
      args: [],
    );
  }

  /// `paste content`
  String get cmdPasteContent {
    return Intl.message(
      'paste content',
      name: 'cmdPasteContent',
      desc: '',
      args: [],
    );
  }

  /// `paste content as plain text`
  String get cmdPasteContentAsPlainText {
    return Intl.message(
      'paste content as plain text',
      name: 'cmdPasteContentAsPlainText',
      desc: '',
      args: [],
    );
  }

  /// `redo`
  String get cmdRedo {
    return Intl.message(
      'redo',
      name: 'cmdRedo',
      desc: '',
      args: [],
    );
  }

  /// `scroll page down`
  String get cmdScrollPageDown {
    return Intl.message(
      'scroll page down',
      name: 'cmdScrollPageDown',
      desc: '',
      args: [],
    );
  }

  /// `scroll page up`
  String get cmdScrollPageUp {
    return Intl.message(
      'scroll page up',
      name: 'cmdScrollPageUp',
      desc: '',
      args: [],
    );
  }

  /// `scroll to bottom`
  String get cmdScrollToBottom {
    return Intl.message(
      'scroll to bottom',
      name: 'cmdScrollToBottom',
      desc: '',
      args: [],
    );
  }

  /// `scroll to top`
  String get cmdScrollToTop {
    return Intl.message(
      'scroll to top',
      name: 'cmdScrollToTop',
      desc: '',
      args: [],
    );
  }

  /// `select all`
  String get cmdSelectAll {
    return Intl.message(
      'select all',
      name: 'cmdSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `Table: add line break`
  String get cmdTableLineBreak {
    return Intl.message(
      'Table: add line break',
      name: 'cmdTableLineBreak',
      desc: '',
      args: [],
    );
  }

  /// `Move to down cell at same offset`
  String get cmdTableMoveToDownCellAtSameOffset {
    return Intl.message(
      'Move to down cell at same offset',
      name: 'cmdTableMoveToDownCellAtSameOffset',
      desc: '',
      args: [],
    );
  }

  /// `Move to left cell if its at start of current cell`
  String get cmdTableMoveToLeftCellIfItsAtStartOfCurrentCell {
    return Intl.message(
      'Move to left cell if its at start of current cell',
      name: 'cmdTableMoveToLeftCellIfItsAtStartOfCurrentCell',
      desc: '',
      args: [],
    );
  }

  /// `Move to right cell if its at the end of current cell`
  String get cmdTableMoveToRightCellIfItsAtTheEndOfCurrentCell {
    return Intl.message(
      'Move to right cell if its at the end of current cell',
      name: 'cmdTableMoveToRightCellIfItsAtTheEndOfCurrentCell',
      desc: '',
      args: [],
    );
  }

  /// `Move to up cell at same offset`
  String get cmdTableMoveToUpCellAtSameOffset {
    return Intl.message(
      'Move to up cell at same offset',
      name: 'cmdTableMoveToUpCellAtSameOffset',
      desc: '',
      args: [],
    );
  }

  /// `Navigate around the cells at same offset`
  String get cmdTableNavigateCells {
    return Intl.message(
      'Navigate around the cells at same offset',
      name: 'cmdTableNavigateCells',
      desc: '',
      args: [],
    );
  }

  /// `Navigate around the cells at same offset in reverse`
  String get cmdTableNavigateCellsReverse {
    return Intl.message(
      'Navigate around the cells at same offset in reverse',
      name: 'cmdTableNavigateCellsReverse',
      desc: '',
      args: [],
    );
  }

  /// `Stop at the beginning of the cell`
  String get cmdTableStopAtTheBeginningOfTheCell {
    return Intl.message(
      'Stop at the beginning of the cell',
      name: 'cmdTableStopAtTheBeginningOfTheCell',
      desc: '',
      args: [],
    );
  }

  /// `toggle bold`
  String get cmdToggleBold {
    return Intl.message(
      'toggle bold',
      name: 'cmdToggleBold',
      desc: '',
      args: [],
    );
  }

  /// `toggle code`
  String get cmdToggleCode {
    return Intl.message(
      'toggle code',
      name: 'cmdToggleCode',
      desc: '',
      args: [],
    );
  }

  /// `toggle highlight`
  String get cmdToggleHighlight {
    return Intl.message(
      'toggle highlight',
      name: 'cmdToggleHighlight',
      desc: '',
      args: [],
    );
  }

  /// `toggle italic`
  String get cmdToggleItalic {
    return Intl.message(
      'toggle italic',
      name: 'cmdToggleItalic',
      desc: '',
      args: [],
    );
  }

  /// `toggle strikethrough`
  String get cmdToggleStrikethrough {
    return Intl.message(
      'toggle strikethrough',
      name: 'cmdToggleStrikethrough',
      desc: '',
      args: [],
    );
  }

  /// `toggle the todo list`
  String get cmdToggleTodoList {
    return Intl.message(
      'toggle the todo list',
      name: 'cmdToggleTodoList',
      desc: '',
      args: [],
    );
  }

  /// `toggle underline`
  String get cmdToggleUnderline {
    return Intl.message(
      'toggle underline',
      name: 'cmdToggleUnderline',
      desc: '',
      args: [],
    );
  }

  /// `undo`
  String get cmdUndo {
    return Intl.message(
      'undo',
      name: 'cmdUndo',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<AppFlowyEditorLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'bn', countryCode: 'BN'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'cs', countryCode: 'CZ'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'VE'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'hi', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'hu', countryCode: 'HU'),
      Locale.fromSubtags(languageCode: 'id', countryCode: 'ID'),
      Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
      Locale.fromSubtags(languageCode: 'ml', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL'),
      Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppFlowyEditorLocalizations> load(Locale locale) =>
      AppFlowyEditorLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
