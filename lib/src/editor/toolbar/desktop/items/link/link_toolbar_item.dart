import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/link/link_menu.dart';
import 'package:appflowy_editor/src/editor/util/link_util.dart';
import 'package:flutter/material.dart';

const _menuWidth = 300;
const _hasTextHeight = 244;
const _noTextHeight = 150;
const _kLinkItemId = 'editor.link';

final linkItem = ToolbarItem(
  id: _kLinkItemId,
  group: 4,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHref = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[AppFlowyRichTextKeys.href] != null,
      );
    });

    final child = SVGIconItemWidget(
      iconName: 'toolbar/link',
      isHighlight: isHref,
      highlightColor: highlightColor,
      iconColor: iconColor,
      onPressed: () {
        showLinkMenu(context, editorState, selection, isHref);
      },
    );

    if (tooltipBuilder != null) {
      return tooltipBuilder(
        context,
        _kLinkItemId,
        AppFlowyEditorL10n.current.link,
        child,
      );
    }

    return child;
  },
);

void showLinkMenu(
  BuildContext context,
  EditorState editorState,
  Selection selection,
  bool isHref,
) {
  // Since link format is only available for single line selection,
  // the first rect(also the only rect) is used as the starting reference point for the [overlay] position

  // get link address if the selection is already a link
  String? linkText;
  if (isHref) {
    linkText = editorState.getDeltaAttributeValueInSelection(
      BuiltInAttributeKey.href,
      selection,
    );
  }

  final (left, top, right, bottom) = _getPosition(editorState, linkText);

  // get node, index and length for formatting text when the link is removed
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null) {
    return;
  }
  final index = selection.normalized.startIndex;
  final length = selection.length;

  OverlayEntry? overlay;

  void dismissOverlay() {
    keepEditorFocusNotifier.decrease();
    overlay?.remove();
    overlay = null;
  }

  keepEditorFocusNotifier.increase();
  overlay = FullScreenOverlayEntry(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    dismissCallback: () => keepEditorFocusNotifier.decrease(),
    builder: (context) {
      return LinkMenu(
        linkText: linkText,
        editorState: editorState,
        onOpenLink: () async {
          await safeLaunchUrl(linkText);
        },
        onSubmitted: (text) async {
          if (isUri(text)) {
            await editorState.formatDelta(selection, {
              BuiltInAttributeKey.href: text,
            });
            dismissOverlay();
          }
        },
        onCopyLink: () {
          AppFlowyClipboard.setData(text: linkText);
          dismissOverlay();
        },
        onRemoveLink: () {
          final transaction = editorState.transaction
            ..formatText(
              node,
              index,
              length,
              {BuiltInAttributeKey.href: null},
            );
          editorState.apply(transaction);
          dismissOverlay();
        },
        onDismiss: dismissOverlay,
      );
    },
  ).build();

  Overlay.of(context, rootOverlay: true).insert(overlay!);
}

// get a proper position for link menu
(double? left, double? top, double? right, double? bottom) _getPosition(
  EditorState editorState,
  String? linkText,
) {
  final rect = editorState.selectionRects().first;

  double? left, right, top, bottom;
  final offset = rect.center;
  final editorOffset = editorState.renderBox!.localToGlobal(Offset.zero);
  final editorWidth = editorState.renderBox!.size.width;
  (left, right) = _getStartEnd(
    editorWidth,
    offset.dx,
    editorOffset.dx,
    _menuWidth,
    rect.left,
    rect.right,
    true,
  );

  final editorHeight = editorState.renderBox!.size.height;
  (top, bottom) = _getStartEnd(
    editorHeight,
    offset.dy,
    editorOffset.dy,
    linkText != null ? _hasTextHeight : _noTextHeight,
    rect.top,
    rect.bottom,
    false,
  );

  return (left, top, right, bottom);
}

// This method calculates the start and end position for a specific
// direction (either horizontal or vertical) in the layout.
(double? start, double? end) _getStartEnd(
  double editorLength,
  double offsetD,
  double editorOffsetD,
  int menuLength,
  double rectStart,
  double rectEnd,
  bool isHorizontal,
) {
  final threshold = editorOffsetD + editorLength - _menuWidth;
  double? start, end;
  if (offsetD > threshold) {
    end = editorOffsetD + editorLength - rectStart - 5;
  } else if (isHorizontal) {
    start = rectStart;
  } else {
    start = rectEnd + 5;
  }

  return (start, end);
}
