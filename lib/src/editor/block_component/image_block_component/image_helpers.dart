import 'package:flutter/material.dart';

class BuildResizableImage extends StatefulWidget {
  const BuildResizableImage({
    Key? key,
    required this.src,
    required this.editable,
    required this.imageWidth,
    required this.imageStream,
    required this.imageStreamListener,
    required this.onResize,
    required this.onFocus,
  }) : super(key: key);
  final String src;
  final bool editable;
  final bool onFocus;
  final double? imageWidth;
  final ImageStream? imageStream;
  final void Function(double width) onResize;
  final ImageStreamListener imageStreamListener;

  @override
  State<BuildResizableImage> createState() => _BuildResizableImageState();
}

class _BuildResizableImageState extends State<BuildResizableImage> {
  double initial = 0.0;
  double imageDistance = 0.0;
  ImageStream? imageStreamValue;

  @override
  Widget build(BuildContext context) {
    //NOTE: Created a class in order to handle local image files later
    final networkImage = ImageFileType()
        .networkImage(widget.src, imageDistance, widget.imageWidth);

    if (widget.imageWidth == null) {
      imageStreamValue = networkImage.image.resolve(const ImageConfiguration())
        ..addListener(widget.imageStreamListener);
    }
    return Stack(
      children: [
        networkImage,
        if (widget.editable) ...[
          BuildEdgeGestures(
            top: 0,
            left: 0,
            right: null,
            bottom: 0,
            width: 5,
            distance: imageDistance,
            onFocus: widget.onFocus,
            imageWidth: widget.imageWidth,
            onResize: widget.onResize,
            initial: initial,
            onUpdate: (distance) {
              setState(() {
                imageDistance = distance;
              });
            },
          ),
          BuildEdgeGestures(
            top: 0,
            left: null,
            right: 0,
            bottom: 0,
            width: 5,
            distance: imageDistance,
            onFocus: widget.onFocus,
            imageWidth: widget.imageWidth,
            onResize: widget.onResize,
            initial: initial,
            onUpdate: (distance) {
              setState(() {
                //BUG: The right side does not have any effect
                //More like it resets the image to full size
                imageDistance = -distance;
              });
            },
          ),
        ],
      ],
    );
  }
}

//NOTE: This class can be used to set image type if image is network or local
class ImageFileType {
  Image networkImage(String src, double distance, double? imageWidth) {
    final network = Image.network(
      src,
      width: imageWidth == null ? null : imageWidth - distance,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null ||
            loadingProgress.cumulativeBytesLoaded ==
                loadingProgress.expectedTotalBytes) {
          return child;
        }

        return const BuildLoadingState();
      },
      errorBuilder: (context, error, stackTrace) => BuildErrorState(
        imageWidth: imageWidth,
      ),
    );
    return network;
  }
}

class BuildLoadingState extends StatelessWidget {
  const BuildLoadingState({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.fromSize(
            size: const Size(18, 18),
            child: const CircularProgressIndicator(),
          ),
          SizedBox.fromSize(
            size: const Size(10, 10),
          ),
          const Text('Loading'),
        ],
      ),
    );
  }
}

class BuildErrorState extends StatelessWidget {
  const BuildErrorState({required this.imageWidth, super.key});
  final double? imageWidth;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: imageWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(width: 1, color: Colors.black),
      ),
      child: const Text('Could not load the image'),
    );
  }
}

class BuildEdgeGestures extends StatefulWidget {
  const BuildEdgeGestures({
    Key? key,
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.width,
    required this.onUpdate,
    required this.distance,
    required this.initial,
    required this.imageWidth,
    required this.onFocus,
    required this.onResize,
  }) : super(key: key);
  //NOTE: Removing top, left, right, bottom, width.
  //Will cause the widget to fail even if we use 0.0
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;
  final double distance;
  final double initial;
  final double? imageWidth;
  final bool onFocus;
  final void Function(double distance)? onUpdate;
  final void Function(double width) onResize;

  @override
  State<BuildEdgeGestures> createState() => _BuildEdgeGesturesState();
}

class _BuildEdgeGesturesState extends State<BuildEdgeGestures> {
  double initialDistance = 0;
  double imageMovedDistance = 0;

  @override
  Widget build(BuildContext context) {
    double? imageWidth = widget.imageWidth;
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      width: widget.width,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          initialDistance = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (widget.onUpdate != null) {
            widget.onUpdate!(details.globalPosition.dx - widget.initial);
          }
        },
        onHorizontalDragEnd: (details) {
          imageWidth = imageWidth! - widget.distance;
          initialDistance = 0;
          imageMovedDistance = 0;

          widget.onResize(imageWidth!);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: widget.onFocus
              ? Center(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
