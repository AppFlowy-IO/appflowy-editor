import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/widget/ignore_parent_gesture.dart';
import 'package:appflowy_editor/src/flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageBlockKeys {
  static const String type = 'page';
}

Node pageNode({
  required Iterable<Node> children,
  Attributes attributes = const {},
}) {
  return Node(
    type: PageBlockKeys.type,
    children: children,
    attributes: attributes,
  );
}

class PageBlockComponentBuilder extends BlockComponentBuilder {
  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    return PageBlockComponent(
      key: blockComponentContext.node.key,
      node: blockComponentContext.node,
      header: blockComponentContext.header,
      footer: blockComponentContext.footer,
    );
  }
}

class PageBlockComponent extends BlockComponentStatelessWidget {
  const PageBlockComponent({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.header,
    this.footer,
  });

  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final scrollController = context.read<EditorScrollController?>();
    final items = node.children;

    if (scrollController == null ||
        scrollController.shrinkWrap ||
        !editorState.editable) {
      return SingleChildScrollView(
        child: Builder(
          builder: (context) {
            final scroller = Scrollable.maybeOf(context);
            if (scroller != null) {
              editorState.updateAutoScroller(scroller);
            }
            return Column(
              children: [
                if (header != null) header!,
                ...items.map(
                  (e) => Padding(
                    padding: editorState.editorStyle.padding,
                    child: editorState.renderer.build(context, e),
                  ),
                ),
                if (footer != null) footer!,
              ],
            );
          },
        ),
      );
    } else {
      int extentCount = 0;
      if (header != null) extentCount++;
      if (footer != null) extentCount++;

      return ScrollablePositionedList.builder(
        shrinkWrap: scrollController.shrinkWrap,
        scrollDirection: Axis.vertical,
        itemCount: items.length + extentCount,
        itemBuilder: (context, index) {
          editorState.updateAutoScroller(Scrollable.of(context));
          if (header != null && index == 0) {
            return IgnoreEditorSelectionGesture(
              child: header!,
            );
          }

          if (footer != null && index == (items.length - 1) + extentCount) {
            return IgnoreEditorSelectionGesture(
              child: footer!,
            );
          }

          return Padding(
            padding: editorState.editorStyle.padding,
            child: editorState.renderer.build(
              context,
              items[index - (header != null ? 1 : 0)],
            ),
          );
        },
        itemScrollController: scrollController.itemScrollController,
        scrollOffsetController: scrollController.scrollOffsetController,
        itemPositionsListener: scrollController.itemPositionsListener,
        scrollOffsetListener: scrollController.scrollOffsetListener,
      );
    }
  }
}
