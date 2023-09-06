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
  });

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final scrollController = context.read<EditorScrollController>();
    final items = node.children;

    if (scrollController.shrinkWrap) {
      return SingleChildScrollView(
        controller: scrollController.scrollController,
        child: Builder(
          builder: (context) {
            editorState.updateAutoScroller(Scrollable.of(context));
            return Column(
              children: items
                  .map((e) => editorState.renderer.build(context, e))
                  .toList(),
            );
          },
        ),
      );
    } else {
      return ScrollablePositionedList.builder(
        shrinkWrap: scrollController.shrinkWrap,
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        itemBuilder: (context, index) {
          editorState.updateAutoScroller(Scrollable.of(context));
          return editorState.renderer.build(
            context,
            items[index],
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
