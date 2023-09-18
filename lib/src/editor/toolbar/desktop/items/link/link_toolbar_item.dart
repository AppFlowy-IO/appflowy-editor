import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/link/link_menu.dart';
import 'package:flutter/material.dart';

const menuWidth = 300;
const hasTextHeight = 244;
const noTextHeight = 150;

final linkItem = ToolbarItem(
  id: 'editor.link',
  group: 4,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHref = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[AppFlowyRichTextKeys.href] != null,
      );
    });

    return SVGIconItemWidget(
      iconName: 'toolbar/link',
      isHighlight: isHref,
      highlightColor: highlightColor,
      tooltip: AppFlowyEditorLocalizations.current.link,
      onPressed: () {
        showLinkMenu(context, editorState, selection, isHref);
      },
    );
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

  final (left, top, right, bottom) = getPosition(editorState, linkText);

  // get node, index and length for formatting text when the link is removed
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null) {
    return;
  }
  final index = selection.normalized.startIndex;
  final length = selection.length;

  OverlayEntry? overlay;

  void dismissOverlay() {
    keepEditorFocusNotifier.value -= 1;
    overlay?.remove();
    overlay = null;
  }

  keepEditorFocusNotifier.value += 1;
  overlay = FullScreenOverlayEntry(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    dismissCallback: () => keepEditorFocusNotifier.value -= 1,
    builder: (context) {
      return LinkMenu(
        linkText: linkText,
        editorState: editorState,
        onOpenLink: () async {
          await safeLaunchUrl(linkText);
        },
        onSubmitted: (text) async {
          await editorState.formatDelta(selection, {
            BuiltInAttributeKey.href: text,
          });
          dismissOverlay();
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

  Overlay.of(context).insert(overlay!);
}

(double? left, double? top, double? right, double? bottom) getPosition(
  EditorState editorState,
  String? linkText,
) {
  final rect = editorState.selectionRects().first;

  double? left, right, top, bottom;
  final offset = rect.center;
  final editorOffset = editorState.renderBox!.localToGlobal(Offset.zero);
  final editorWidth = editorState.renderBox!.size.width;
  final thresholdX = editorOffset.dx + editorWidth - menuWidth;
  if (offset.dx > thresholdX) {
    right = editorOffset.dx + editorWidth - rect.left - 5;
  } else {
    left = rect.right + 5;
  }
  final editorHeight = editorState.renderBox!.size.height;
  final thresholdY = editorOffset.dy +
      editorHeight -
      (linkText != null ? hasTextHeight : noTextHeight);
  if (offset.dy > thresholdY) {
    bottom = editorOffset.dy + editorHeight - rect.top - 5;
  } else {
    top = rect.bottom + 5;
  }

  return (left, top, right, bottom);
}

