import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/default_text_operations/format_rich_text_style.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

typedef ToolbarItemEventHandler = void Function(
  EditorState editorState,
  BuildContext context,
);
typedef ToolbarItemValidator = bool Function(EditorState editorState);
typedef ToolbarItemHighlightCallback = bool Function(EditorState editorState);

class ToolbarItem {
  ToolbarItem({
    required this.id,
    required this.group,
    this.type = 1,
    this.tooltipsMessage = '',
    this.iconBuilder,
    this.validator,
    this.highlightCallback,
    this.handler,
    this.itemBuilder,
    this.isActive,
    this.builder,
  });

  final String id;
  final int group;
  final bool Function(EditorState editorState)? isActive;
  final Widget Function(BuildContext context, EditorState editorState)? builder;

  // deprecated
  final int type;
  final String tooltipsMessage;

  final ToolbarItemValidator? validator;

  final Widget Function(bool isHighlight)? iconBuilder;
  final ToolbarItemEventHandler? handler;
  final ToolbarItemHighlightCallback? highlightCallback;

  final Widget Function(BuildContext context, EditorState editorState)?
      itemBuilder;

  factory ToolbarItem.divider() {
    return ToolbarItem(
      id: 'divider',
      type: -1,
      group: -1,
      iconBuilder: (_) => const EditorSvg(name: 'toolbar/divider'),
      validator: (editorState) => true,
      handler: (editorState, context) {},
      highlightCallback: (editorState) => false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! ToolbarItem) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

const baseToolbarIndex = 1;
List<ToolbarItem> defaultToolbarItems = [
  ToolbarItem(
    id: 'appflowy.toolbar.h1',
    type: 1,
    group: baseToolbarIndex,
    tooltipsMessage: AppFlowyEditorLocalizations.current.heading1,
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/h1',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _onlyShowInSingleTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.heading,
      (value) => value == BuiltInAttributeKey.h1,
    ),
    handler: (editorState, context) =>
        formatHeading(editorState, BuiltInAttributeKey.h1),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.h2',
    type: 1,
    group: baseToolbarIndex,
    tooltipsMessage: AppFlowyEditorLocalizations.current.heading2,
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/h2',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _onlyShowInSingleTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.heading,
      (value) => value == BuiltInAttributeKey.h2,
    ),
    handler: (editorState, context) =>
        formatHeading(editorState, BuiltInAttributeKey.h2),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.h3',
    type: 1,
    group: baseToolbarIndex,
    tooltipsMessage: AppFlowyEditorLocalizations.current.heading3,
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/h3',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _onlyShowInSingleTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.heading,
      (value) => value == BuiltInAttributeKey.h3,
    ),
    handler: (editorState, context) =>
        formatHeading(editorState, BuiltInAttributeKey.h3),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.bold',
    type: 2,
    group: baseToolbarIndex + 1,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.bold}${_shortcutTooltips("⌘ + B", "CTRL + B", "CTRL + B")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/bold',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.bold,
      (value) => value == true,
    ),
    handler: (editorState, context) => formatBold(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.italic',
    type: 2,
    group: baseToolbarIndex + 1,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.italic}${_shortcutTooltips("⌘ + I", "CTRL + I", "CTRL + I")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/italic',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.italic,
      (value) => value == true,
    ),
    handler: (editorState, context) => formatItalic(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.underline',
    type: 2,
    group: baseToolbarIndex + 1,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.underline}${_shortcutTooltips("⌘ + U", "CTRL + U", "CTRL + U")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/underline',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.underline,
      (value) => value == true,
    ),
    handler: (editorState, context) => formatUnderline(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.strikethrough',
    type: 2,
    group: baseToolbarIndex + 1,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.strikethrough}${_shortcutTooltips("⌘ + SHIFT + S", "CTRL + SHIFT + S", "CTRL + SHIFT + S")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/strikethrough',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.strikethrough,
      (value) => value == true,
    ),
    handler: (editorState, context) => formatStrikethrough(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.code',
    type: 2,
    group: baseToolbarIndex + 1,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.embedCode}${_shortcutTooltips("⌘ + E", "CTRL + E", "CTRL + E")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/code',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.code,
      (value) => value == true,
    ),
    handler: (editorState, context) => formatEmbedCode(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.quote',
    type: 3,
    group: baseToolbarIndex + 2,
    tooltipsMessage: AppFlowyEditorLocalizations.current.quote,
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/quote',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _onlyShowInSingleTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.subtype,
      (value) => value == BuiltInAttributeKey.quote,
    ),
    handler: (editorState, context) {
      formatQuote(editorState);
    },
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.bulleted_list',
    type: 3,
    group: baseToolbarIndex + 2,
    tooltipsMessage: AppFlowyEditorLocalizations.current.bulletedList,
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/bulleted_list',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _onlyShowInSingleTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.subtype,
      (value) => value == BuiltInAttributeKey.bulletedList,
    ),
    handler: (editorState, context) => formatBulletedList(editorState),
  ),
  ToolbarItem(
    id: 'appflowy.toolbar.highlight',
    type: 4,
    group: baseToolbarIndex + 2,
    tooltipsMessage:
        "${AppFlowyEditorLocalizations.current.highlight}${_shortcutTooltips("⌘ + SHIFT + H", "CTRL + SHIFT + H", "CTRL + SHIFT + H")}",
    iconBuilder: (isHighlight) => EditorSvg(
      name: 'toolbar/highlight',
      color: isHighlight ? Colors.lightBlue : null,
    ),
    validator: _showInBuiltInTextSelection,
    highlightCallback: (editorState) => _allSatisfy(
      editorState,
      BuiltInAttributeKey.highlightColor,
      (value) {
        return value != null && value != '0x00000000'; // transparent color;
      },
    ),
    handler: (editorState, context) => formatHighlight(
      editorState,
      editorState.editorStyle.highlightColorHex!,
    ),
  ),
];

String _shortcutTooltips(
  String? macOSString,
  String? windowsString,
  String? linuxString,
) {
  if (kIsWeb) return '';
  if (Platform.isMacOS && macOSString != null) {
    return '\n$macOSString';
  } else if (Platform.isWindows && windowsString != null) {
    return '\n$windowsString';
  } else if (Platform.isLinux && linuxString != null) {
    return '\n$linuxString';
  }
  return '';
}

ToolbarItemValidator _onlyShowInSingleTextSelection = (editorState) {
  final result = _showInBuiltInTextSelection(editorState);
  if (!result) {
    return false;
  }
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  return (nodes.length == 1 && nodes.first is TextNode);
};

ToolbarItemValidator _showInBuiltInTextSelection = (editorState) {
  final nodes = editorState.service.selectionService.currentSelectedNodes
      .whereType<TextNode>()
      .where(
        (textNode) =>
            BuiltInAttributeKey.globalStyleKeys.contains(textNode.type),
      );
  return nodes.isNotEmpty;
};

bool _allSatisfy(
  EditorState editorState,
  String styleKey,
  bool Function(dynamic value) test,
) {
  final selection = editorState.selection;
  return selection != null &&
      editorState.selectedTextNodes.allSatisfyInSelection(
        selection,
        styleKey,
        test,
      );
}

bool onlyShowInSingleSelectionAndTextType(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return false;
  }
  final node = editorState.getNodeAtPath(selection.start.path);
  return node?.delta != null;
}

bool onlyShowInTextType(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }
  final nodes = editorState.getNodesInSelection(selection);
  return nodes.every((element) => element.delta != null);
}
