import 'package:flutter/material.dart';

class NetworkImageNode extends StatefulWidget {
  NetworkImageNode({
    Key? key,
    required BuildContext context,
    required this.alignment,
    required this.onFocus,
    required this.src,
    required this.editable,
    this.imageWidth,
    required this.distance,
    this.imageStream,
    required this.imageStreamListener,
    required this.initial,
    required this.onResize,
  }) : super(key: key);
  final String src;
  final bool editable;
  final double initial;
  final double? imageWidth;
  final double distance;
  final ImageStream? imageStream;
  final ImageStreamListener imageStreamListener;

  final void Function(double width) onResize;

  final Alignment alignment;
  bool
      onFocus; //NOTE: Throws immutable warning since its note final & constructor isnt cons

  @override
  State<NetworkImageNode> createState() => _NetworkImageNodeState();
}

class _NetworkImageNodeState extends State<NetworkImageNode> {
  @override
  Widget build(buildContext) {
    print('ImageWidth From NetworkImage: ${widget.imageWidth}');
    return Align(
      alignment: widget.alignment,
      child: MouseRegion(
        onEnter: (event) => setState(() {
          widget.onFocus = true;
        }),
        onExit: (event) => setState(() {
          widget.onFocus = false;
        }),
        child: BuildResizableImage(
          context: context,
          src: widget.src,
          editable: widget.editable,
          imageWidth: widget.imageWidth,
          distance: widget.distance,
          imageStream: widget.imageStream,
          imageStreamListener: widget.imageStreamListener,
          initial: widget.initial,
          onResize: widget.onResize,
          onFocus: widget.onFocus,
        ),
      ),
    );
  }
}

class BuildResizableImage extends StatefulWidget {
  BuildResizableImage({
    Key? key,
    required BuildContext context,
    required this.src,
    required this.editable,
    this.imageWidth,
    required this.distance,
    this.imageStream,
    required this.imageStreamListener,
    required this.onFocus,
    required this.onResize,
    required this.initial,
  }) : super(key: key);
  final String src;
  final bool editable;
  bool onFocus;
  final double? imageWidth;
  double initial;
  double distance;
  ImageStream? imageStream;
  final void Function(double width) onResize;
  ImageStreamListener imageStreamListener;

  @override
  State<BuildResizableImage> createState() => _BuildResizableImageState();
}

class _BuildResizableImageState extends State<BuildResizableImage> {
  @override
  Widget build(context) {
    print('ImageWidth From Resize: ${widget.imageWidth}');
    //NOTE: Created a class in order to handle local image files later
    final networkImage = ImageFileType()
        .networkImage(widget.src, widget.distance, widget.imageWidth);

    if (widget.imageWidth == null) {
      widget.imageStream = networkImage.image
          .resolve(const ImageConfiguration())
        ..addListener(widget.imageStreamListener);
    }
    return Stack(
      children: [
        networkImage,
        if (widget.editable) ...[
          BuildEdgeGestures(
            top: 0,
            left: 0,
            bottom: 0,
            width: 5,
            distance: widget.distance,
            onFocus: widget.onFocus,
            imageWidth: widget.imageWidth,
            onResize: widget.onResize,
            initial: widget.initial,
            onUpdate: (distance) {
              setState(() {
                widget.distance = distance;
              });
            },
          ),
          BuildEdgeGestures(
            top: 0,
            right: 0,
            bottom: 0,
            width: 5,
            distance: widget.distance,
            onFocus: widget.onFocus,
            imageWidth: widget.imageWidth,
            onResize: widget.onResize,
            initial: widget.initial,
            onUpdate: (distance) {
              setState(() {
                widget.distance = -distance;
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
  BuildEdgeGestures({
    Key? key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width,
    required this.onUpdate,
    required this.distance,
    required this.initial,
    required this.imageWidth,
    required this.onFocus,
    required this.onResize,
  }) : super(key: key);
  double? top;
  double? left;
  double? right;
  double? bottom;
  double? width;
  double distance;
  double initial;
  double? imageWidth;

  bool onFocus;

  void Function(double distance)? onUpdate;
  void Function(double width) onResize;

  @override
  State<BuildEdgeGestures> createState() => _BuildEdgeGesturesState();
}

class _BuildEdgeGesturesState extends State<BuildEdgeGestures> {
  @override
  Widget build(BuildContext context) {
    print(widget.width);
    print(widget.imageWidth);
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      width: widget.width,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          widget.initial = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (widget.onUpdate != null) {
            widget.onUpdate!(details.globalPosition.dx - widget.initial);
          }
        },
        onHorizontalDragEnd: (details) {
          widget.imageWidth = widget.imageWidth! - widget.distance;
          widget.initial = 0;
          widget.distance = 0;

          widget.onResize(widget.imageWidth!);
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

