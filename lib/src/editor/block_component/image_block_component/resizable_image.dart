import 'dart:io';
import 'package:flutter/material.dart';
import 'image_helpers.dart';

class ResizableImage extends StatefulWidget {
  const ResizableImage({
    super.key,
    required this.alignment,
    required this.editable,
    required this.onResize,
    required this.width,
    required this.src,
    this.height,
  });

  final String src;
  final double width;
  final double? height;
  final Alignment alignment;
  final bool editable;

  final void Function(double width) onResize;

  @override
  State<ResizableImage> createState() => _ResizableImageState();
}

class _ResizableImageState extends State<ResizableImage> {
  late double imageWidth;

  double initialOffset = 0;
  double moveDistance = 0;

  Image? _cacheImage;

  @visibleForTesting
  bool onFocus = false;

  @override
  void initState() {
    super.initState();

    imageWidth = widget.width;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: SizedBox(
        width: imageWidth - moveDistance,
        height: widget.height,
        child: MouseRegion(
          onEnter: (event) => setState(() {
            onFocus = true;
          }),
          onExit: (event) => setState(() {
            onFocus = false;
          }),
          child: _buildResizableImage(context),
        ),
      ),
    );
  }

//NOTE: Context works fine if we use this, but doesnt work when we pile stuff on it
  Widget _buildResizableImage(BuildContext context) {
    Widget child;
    //NOTE: SImilar to how the ImageFileType works just that there are alot of ifs
    final regex = RegExp('^(http|https)://');
    final url = widget.src;
    if (regex.hasMatch(url)) {
      _cacheImage ??= ImageFileType().networkImage(widget.src, widget.width);
      child = _cacheImage!;
    } else {
      // load local file
      _cacheImage ??= Image.file(File(url));
      child = _cacheImage!;
    }
    return Stack(
      children: [
        child,
        if (widget.editable) ...[
          /*NOTE: for some reason this BuildEdgeGestures resets image
           * size then resizes the image.
           * Although the _buildEdgeGesture function didn't do that
           */
          BuildEdgeGestures(
            context,
            top: 0,
            left: 5,
            right: null,
            bottom: 0,
            width: 5,
            onUpdate: (distance) {
              setState(() {
                moveDistance = distance;
              });
            },
            onFocus: onFocus,
            imageWidth: imageWidth,
            onResize: widget.onResize,
            distance: moveDistance,
          ),
          BuildEdgeGestures(
            context,
            top: 0,
            left: null,
            right: 5,
            bottom: 0,
            width: 5,
            onUpdate: (distance) {
              setState(() {
                moveDistance = -distance;
              });
            },
            onFocus: onFocus,
            imageWidth: imageWidth,
            onResize: widget.onResize,
            distance: moveDistance,
          ),
        ],
      ],
    );
  }
}
