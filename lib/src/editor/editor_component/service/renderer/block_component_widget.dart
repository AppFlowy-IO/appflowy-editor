import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_component_action_wrapper.dart';
import 'package:flutter/material.dart';

mixin BlockComponentWidget on Widget {
  Node get node;
  BlockComponentConfiguration get configuration;
  BlockComponentActionBuilder? get actionBuilder;
  bool get showActions;
}

class BlockComponentStatelessWidget extends StatelessWidget
    implements BlockComponentWidget {
  const BlockComponentStatelessWidget({
    super.key,
    required this.node,
    required this.configuration,
    this.showActions = false,
    this.actionBuilder,
  });

  @override
  final Node node;
  @override
  final BlockComponentConfiguration configuration;
  @override
  final BlockComponentActionBuilder? actionBuilder;
  @override
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class BlockComponentStatefulWidget extends StatefulWidget
    implements BlockComponentWidget {
  const BlockComponentStatefulWidget({
    super.key,
    required this.node,
    required this.configuration,
    this.showActions = false,
    this.actionBuilder,
  });

  @override
  final Node node;
  @override
  final BlockComponentConfiguration configuration;
  @override
  final BlockComponentActionBuilder? actionBuilder;
  @override
  final bool showActions;

  @override
  State<BlockComponentStatefulWidget> createState() =>
      _BlockComponentStatefulWidgetState();
}

class _BlockComponentStatefulWidgetState
    extends State<BlockComponentStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
