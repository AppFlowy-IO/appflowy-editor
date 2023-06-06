import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'image_block_widget.dart';

class ImageBlockKeys {
  ImageBlockKeys._();

  static const String type = 'image';

  /// The align data of a image block.
  ///
  /// The value is a String.
  /// left, center, right
  static const String align = 'align';

  /// The image src of a image block.
  ///
  /// The value is a String.
  /// only support network image now.
  static const String url = 'url';

  /// The height of a image block.
  ///
  /// The value is a double.
  static const String width = 'width';

  /// The width of a image block.
  ///
  /// The value is a double.
  static const String height = 'height';
}

Node imageNode({
  required String url,
  String align = 'center',
  double? height,
  double? width,
}) {
  return Node(
    type: ImageBlockKeys.type,
    attributes: {
      ImageBlockKeys.url: url,
      ImageBlockKeys.align: align,
      ImageBlockKeys.height: height,
      ImageBlockKeys.width: width,
    },
  );
}

class ImageBlockComponentBuilder extends BlockComponentBuilder {
  ImageBlockComponentBuilder({
    this.configuration = const BlockComponentConfiguration(),
  });

  @override
  final BlockComponentConfiguration configuration;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return ImageBlockComponentWidget(
      key: node.key,
      node: node,
      showActions: showActions(node),
      configuration: configuration,
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) =>
      node.delta == null &&
      node.children.isEmpty &&
      node.attributes[ImageBlockKeys.url] is String;
}

class ImageBlockComponentWidget extends BlockComponentStatefulWidget {
  const ImageBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<ImageBlockComponentWidget> createState() =>
      _ImageBlockComponentWidgetState();
}

class _ImageBlockComponentWidgetState extends State<ImageBlockComponentWidget> {
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final attributes = node.attributes;
    final src = attributes[ImageBlockKeys.url];
    final align = attributes[ImageBlockKeys.align] ?? 'center';
    final width = attributes[ImageBlockKeys.width]?.toDouble();

    Widget child = ImageNodeWidget(
      node: node,
      src: src,
      width: width,
      editable: editorState.editable,
      alignment: _textToAlignment(align),
      onResize: (width) {
        final transaction = editorState.transaction
          ..updateNode(node, {
            ImageBlockKeys.width: width,
          });
        editorState.apply(transaction);
      },
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  Alignment _textToAlignment(String text) {
    if (text == 'left') {
      return Alignment.centerLeft;
    } else if (text == 'right') {
      return Alignment.centerRight;
    }
    return Alignment.center;
  }
}
