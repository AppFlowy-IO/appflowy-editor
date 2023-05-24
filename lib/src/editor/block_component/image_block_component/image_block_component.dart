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
  ImageBlockComponentBuilder();

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return ImageBlockComponentWidget(
      node: node,
      showActions: showActions(node),
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

    return ImageNodeWidget(
      key: node.key,
      node: node,
      src: src,
      width: width,
      editable: editorState.editable,
      alignment: _textToAlignment(align),
      onResize: (width) {
        final transaction = editorState.transaction
          ..updateNode(node, {
            'width': width,
          });
        editorState.apply(transaction);
      },
    );
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

// class ImageNodeBuilder extends NodeWidgetBuilder<Node>
//     with ActionProvider<Node> {
//   @override
//   Widget build(NodeWidgetContext<Node> context) {
//     final src = context.node.attributes['image_src'];
//     final align = context.node.attributes['align'];
//     double? width;
//     if (context.node.attributes.containsKey('width')) {
//       width = context.node.attributes['width'].toDouble();
//     }
//     return ImageNodeWidget(
//       key: context.node.key,
//       node: context.node,
//       src: src,
//       width: width,
//       editable: context.editorState.editable,
//       alignment: _textToAlignment(align),
//       onResize: (width) {
//         final transaction = context.editorState.transaction
//           ..updateNode(context.node, {
//             'width': width,
//           });
//         context.editorState.apply(transaction);
//       },
//     );
//   }

//   @override
//   NodeValidator<Node> get nodeValidator => ((node) {
//         return node.type == 'image' &&
//             node.attributes.containsKey('image_src') &&
//             node.attributes.containsKey('align');
//       });

//   @override
//   List<ActionMenuItem> actions(NodeWidgetContext<Node> context) {
//     return [
//       ActionMenuItem.svg(
//         name: 'image_toolbar/align_left',
//         selected: () {
//           final align = context.node.attributes['align'];
//           return _textToAlignment(align) == Alignment.centerLeft;
//         },
//         onPressed: () => _onAlign(context, Alignment.centerLeft),
//       ),
//       ActionMenuItem.svg(
//         name: 'image_toolbar/align_center',
//         selected: () {
//           final align = context.node.attributes['align'];
//           return _textToAlignment(align) == Alignment.center;
//         },
//         onPressed: () => _onAlign(context, Alignment.center),
//       ),
//       ActionMenuItem.svg(
//         name: 'image_toolbar/align_right',
//         selected: () {
//           final align = context.node.attributes['align'];
//           return _textToAlignment(align) == Alignment.centerRight;
//         },
//         onPressed: () => _onAlign(context, Alignment.centerRight),
//       ),
//       ActionMenuItem.separator(),
//       ActionMenuItem.svg(
//         name: 'image_toolbar/copy',
//         onPressed: () {
//           final src = context.node.attributes['image_src'];
//           AppFlowyClipboard.setData(text: src);
//         },
//       ),
//       ActionMenuItem.svg(
//         name: 'image_toolbar/delete',
//         onPressed: () {
//           final transaction = context.editorState.transaction
//             ..deleteNode(context.node);
//           context.editorState.apply(transaction);
//         },
//       ),
//     ];
//   }

//   Alignment _textToAlignment(String text) {
//     if (text == 'left') {
//       return Alignment.centerLeft;
//     } else if (text == 'right') {
//       return Alignment.centerRight;
//     }
//     return Alignment.center;
//   }

//   String _alignmentToText(Alignment alignment) {
//     if (alignment == Alignment.centerLeft) {
//       return 'left';
//     } else if (alignment == Alignment.centerRight) {
//       return 'right';
//     }
//     return 'center';
//   }

//   void _onAlign(NodeWidgetContext context, Alignment alignment) {
//     final transaction = context.editorState.transaction
//       ..updateNode(context.node, {
//         'align': _alignmentToText(alignment),
//       });
//     context.editorState.apply(transaction);
//   }
// }
