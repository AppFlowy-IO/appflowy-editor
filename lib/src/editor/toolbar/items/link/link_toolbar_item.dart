import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/link/link_menu.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/utils/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';
import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:flutter/material.dart';

final linkItem = ToolbarItem(
  id: 'editor.link',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHref = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['href'] != null,
      );
    });

    return IconItemWidget(
      iconName: 'toolbar/link',
      isHighlight: isHref,
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
  final rect = editorState.selectionRects.first;

  // get node, index and length for formatting text when the link is removed
  final node = editorState.getNodeAtPath(selection.end.path);
  final index =
      selection.isBackward ? selection.start.offset : selection.end.offset;
  final length = (selection.start.offset - selection.end.offset).abs();

  // get link address if the selection is already a link
  String? linkText;
  if (isHref) {
    linkText = editorState.getDeltaAttributeValueInSelection(
      BuiltInAttributeKey.href,
      selection,
    );
  }
  OverlayEntry? overlay;

  void dismissOverlay() {
    overlay?.remove();
    overlay = null;
    editorState.service.keyboardService?.enable();
  }

  overlay = FullScreenOverlayEntry(
    top: rect.bottom + 5,
    left: rect.left + 10,
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
              node!,
              index,
              length,
              {BuiltInAttributeKey.href: null},
            );
          editorState.apply(transaction);
          dismissOverlay();
        },
      );
    },
  ).build();

  Overlay.of(context).insert(overlay!);
  editorState.service.keyboardService?.disable();
}
