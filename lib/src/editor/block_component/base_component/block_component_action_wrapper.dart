import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_action.dart';
import 'package:flutter/material.dart';

typedef BlockComponentActionBuilder = Widget Function(
  BuildContext context,
  BlockComponentActionState state,
);

typedef BlockComponentActionTrailingBuilder = Widget Function(
  BuildContext context,
  BlockComponentActionState state,
);

/// Function type for wrapping block content (excludes actions)
typedef BlockContentWrapper = Widget Function(
  BuildContext context, {
  required Node node,
  required Widget child,
});

class BlockComponentActionWrapper extends StatefulWidget {
  const BlockComponentActionWrapper({
    super.key,
    required this.node,
    required this.child,
    required this.actionBuilder,
    this.actionTrailingBuilder,
    this.contentWrapper,
  });

  final Node node;
  final Widget child;
  final BlockComponentActionBuilder actionBuilder;
  final BlockComponentActionTrailingBuilder? actionTrailingBuilder;
  /// Optional wrapper applied only to block content (not actions)
  final BlockContentWrapper? contentWrapper;

  @override
  State<BlockComponentActionWrapper> createState() =>
      _BlockComponentActionWrapperState();
}

class _BlockComponentActionWrapperState
    extends State<BlockComponentActionWrapper>
    implements BlockComponentActionState {
  final showActionsNotifier = ValueNotifier<bool>(false);

  bool isDisposed = false;

  bool _alwaysShowActions = false;

  bool get alwaysShowActions => _alwaysShowActions;

  @override
  set alwaysShowActions(bool alwaysShowActions) {
    if (isDisposed) {
      return;
    }
    _alwaysShowActions = alwaysShowActions;
    if (_alwaysShowActions == false && showActionsNotifier.value == true) {
      showActionsNotifier.value = false;
    }
  }

  @override
  void initState() {
    super.initState();

    if (forceShowBlockAction) {
      alwaysShowActions = true;
      showActionsNotifier.value = true;
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    showActionsNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply contentWrapper only to the block content, not the actions
    Widget content = widget.child;
    if (widget.contentWrapper != null) {
      content = widget.contentWrapper!(
        context,
        node: widget.node,
        child: content,
      );
    }

    return MouseRegion(
      onEnter: (_) => showActionsNotifier.value = true,
      onExit: (_) => showActionsNotifier.value = alwaysShowActions || false,
      hitTestBehavior: HitTestBehavior.opaque,
      opaque: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: showActionsNotifier,
            builder: (context, value, child) => BlockComponentActionContainer(
              node: widget.node,
              showActions: value,
              actionBuilder: (context) => widget.actionBuilder(context, this),
            ),
          ),
          if (widget.actionTrailingBuilder != null)
            widget.actionTrailingBuilder!(
              context,
              this,
            ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
