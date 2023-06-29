import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'resizable_image.dart';

enum ImageSourceType {
  network,
  file;

  static ImageSourceType fromString(String value) {
    switch (value) {
      case 'network':
        return ImageSourceType.network;
      case 'file':
        return ImageSourceType.file;
      default:
        return ImageSourceType.network; // compatible with old version
    }
  }
}

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

  /// The image source type of a image block.
  ///
  /// The value is a String.
  /// network, file
  static const String imageSourceType = 'imageSourceType';

  /// The image content of a image block.
  ///
  /// base64 image content
  static const String content = 'content';
}

Node imageNode({
  required ImageSourceType imageSourceType,
  String? content,
  String? url,
  String align = 'center',
  double? height,
  double? width,
}) {
  return Node(
    type: ImageBlockKeys.type,
    attributes: {
      ImageBlockKeys.url: url,
      ImageBlockKeys.content: content,
      ImageBlockKeys.align: align,
      ImageBlockKeys.height: height,
      ImageBlockKeys.width: width,
      ImageBlockKeys.imageSourceType: imageSourceType.name,
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
  bool validate(Node node) => node.delta == null && node.children.isEmpty;
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

class _ImageBlockComponentWidgetState extends State<ImageBlockComponentWidget>
    with SelectableMixin {
  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final attributes = node.attributes;
    final src = attributes[ImageBlockKeys.url];
    final content = attributes[ImageBlockKeys.content];
    final alignment = AlignmentExtension.fromString(
      attributes[ImageBlockKeys.align] ?? 'center',
    );
    final width = attributes[ImageBlockKeys.width]?.toDouble() ??
        MediaQuery.of(context).size.width;
    final imageSourceType = ImageSourceType.fromString(
      attributes[ImageBlockKeys.imageSourceType],
    );

    Widget child = ResizableImage(
      src: src,
      content: content,
      width: width,
      editable: editorState.editable,
      alignment: alignment,
      type: imageSourceType,
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

    return blockPadding(
      child,
      widget.node,
      widget.configuration.padding(node),
    );
  }

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Rect? getCursorRectInPosition(Position position) {
    final size = _renderBox.size;
    return Rect.fromLTWH(-size.width / 2.0, 0, size.width, size.height);
  }

  @override
  List<Rect> getRectsInSelection(Selection selection) =>
      [Offset.zero & _renderBox.size];

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  Offset localToGlobal(Offset offset) => _renderBox.localToGlobal(offset);
}

extension AlignmentExtension on Alignment {
  static Alignment fromString(String name) {
    switch (name) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}
