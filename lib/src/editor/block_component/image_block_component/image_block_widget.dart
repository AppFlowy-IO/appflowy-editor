import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/core/location/position.dart';
import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/extensions/object_extensions.dart';
import 'package:appflowy_editor/src/render/selection/selectable.dart';
import 'package:flutter/material.dart';
import './image_helpers.dart';

class ImageNodeWidget extends StatefulWidget {
  const ImageNodeWidget({
    Key? key,
    required this.node,
    required this.src,
    this.width,
    required this.alignment,
    required this.editable,
    required this.onResize,
  }) : super(key: key);

  final Node node;
  final String src;
  final double? width;
  final Alignment alignment;
  final bool editable;
  final void Function(double width) onResize;

  @override
  State<ImageNodeWidget> createState() => ImageNodeWidgetState();
}

class ImageNodeWidgetState extends State<ImageNodeWidget> with SelectableMixin {
  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  final _imageKey = GlobalKey();

  double? _imageWidth;
  final double _initial = 0;
  final double _distance = 0;

  @visibleForTesting
  bool onFocus = false;

  ImageStream? _imageStream;
  late ImageStreamListener _imageStreamListener;

  @override
  void initState() {
    super.initState();

    _imageWidth = widget.width;
    _imageStreamListener = ImageStreamListener(
      (image, _) {
        _imageWidth = _imageKey.currentContext
            ?.findRenderObject()
            ?.unwrapOrNull<RenderBox>()
            ?.size
            .width;
      },
    );
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // only support network image.
    //NOTE: NetworkImageNode, BuildResizableImage are roughly the same
    //NOTE: only just removed NetworkImage since it only had alignment
    return Container(
      key: _imageKey,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Align(
        alignment: widget.alignment,
        child: MouseRegion(
          onEnter: (event) => setState(() => onFocus = true),
          onExit: (event) => setState(() => onFocus = false),
          child: BuildResizableImage(
            context: context,
            src: widget.src,
            editable: widget.editable,
            imageWidth: _imageWidth,
            distance: _distance,
            imageStream: _imageStream,
            imageStreamListener: _imageStreamListener,
            onFocus: onFocus,
            initial: _initial,
            onResize: widget.onResize,
          ),
        ),
      ),
    );
  }

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Position start() {
    return Position(path: widget.node.path, offset: 0);
  }

  @override
  Position end() {
    return start();
  }

  @override
  Position getPositionInOffset(Offset start) {
    return end();
  }

  @override
  Rect? getCursorRectInPosition(Position position) {
    final size = _renderBox.size;
    return Rect.fromLTWH(-size.width / 2.0, 0, size.width, size.height);
  }

  @override
  List<Rect> getRectsInSelection(Selection selection) {
    final renderBox = context.findRenderObject() as RenderBox;
    return [Offset.zero & renderBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    if (start <= end) {
      return Selection(start: this.start(), end: this.end());
    } else {
      return Selection(start: this.end(), end: this.start());
    }
  }

  @override
  Offset localToGlobal(Offset offset) {
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(offset);
  }
}
