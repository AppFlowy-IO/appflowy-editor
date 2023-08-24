import 'package:flutter/material.dart';

//NOTE: This class can be used to set image type if image is network or local
class ImageFileType {
  Image networkImage(String src, double? imageWidth) {
    final network = Image.network(
      src,
      width: imageWidth,
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
  const BuildEdgeGestures(
    BuildContext context, {
    super.key,
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.width,
    required this.onUpdate,
    required this.distance,
    required this.imageWidth,
    required this.onFocus,
    required this.onResize,
  });
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double width;
  final double distance;
  final double imageWidth;
  final bool onFocus;
  final void Function(double width) onResize;
  final void Function(double width)? onUpdate;

  @override
  State<BuildEdgeGestures> createState() => _BuildEdgeGesturesState();
}

class _BuildEdgeGesturesState extends State<BuildEdgeGestures> {
  double initialOffset = 0.0;
  double imageWidth = 0.0;
  double imageMovedDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    imageWidth = widget.imageWidth;
    imageMovedDistance = widget.distance;
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      width: widget.width,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          initialOffset = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (widget.onUpdate != null) {
            widget.onUpdate!((details.globalPosition.dx - initialOffset) * 2.0);
          }
        },
        onHorizontalDragEnd: (details) {
          imageWidth = imageWidth - imageMovedDistance;
          initialOffset = 0;
          imageMovedDistance = 0;
          widget.onResize(imageWidth);
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
