import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
    final scrollController = context.read<EditorScrollController>();
    final items = node.children;
    int extentCount = 0;
    if (header != null) extentCount++;
    if (footer != null) extentCount++;

    if (scrollController.shrinkWrap) {
      return SingleChildScrollView(
        controller: scrollController.scrollController,
        child: Builder(
          builder: (context) {
            editorState.updateAutoScroller(Scrollable.of(context));
            return Padding(
              padding: editorState.editorStyle.padding,
              child: Column(
                children: [
                  if (header != null) header!,
                  ...items
                      .map((e) => editorState.renderer.build(context, e))
                      .toList(),
                  if (footer != null) footer!,
                ],
              ),
            );
          },
        ),
      );
    } else {
      return ScrollablePositionedList.builder(
        shrinkWrap: scrollController.shrinkWrap,
        padding: editorState.editorStyle.padding,
        scrollDirection: Axis.vertical,
        itemCount: items.length + extentCount,
        itemBuilder: (context, index) {
          editorState.updateAutoScroller(Scrollable.of(context));
          if (header != null && index == 0) return header!;
          if (footer != null && index == items.length + 1) return footer!;
          return editorState.renderer.build(
            context,
            items[index - (header != null ? 1 : 0)],
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
