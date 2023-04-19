import 'dart:io';

import 'package:appflowy_editor/src/block_component/base_component/service/scroll/desktop_scroll_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    Key? key,
    this.scrollController,
    required this.child,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Widget child;

  @override
  State<ScrollServiceWidget> createState() => _ScrollServiceWidgetState();
}

class _ScrollServiceWidgetState extends State<ScrollServiceWidget> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return DesktopScrollService(
        child: widget.child,
      );
    } else if (Platform.isIOS || Platform.isAndroid) {
      return DesktopScrollService(
        child: widget.child,
      );
    }
    throw UnimplementedError();
  }
}
