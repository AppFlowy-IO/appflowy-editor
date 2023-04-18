import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoListBlockKeys {
  TodoListBlockKeys._();

  /// The checked data of a todo list block.
  ///
  /// The value is a boolean.
  static const String checked = 'checked';
}

class TodoListBlockComponentBuilder extends NodeWidgetBuilder<Node> {
  TodoListBlockComponentBuilder({
    this.padding = const EdgeInsets.all(0.0),
    this.textStyleBuilder,
    this.icon,
  });

  /// The padding of the todo list block.
  final EdgeInsets padding;

  /// The text style of the todo list block.
  final TextStyle Function(bool checked)? textStyleBuilder;

  /// The icon of the todo list block.
  final Widget? Function(bool checked)? icon;

  @override
  Widget build(NodeWidgetContext<Node> context) {
    return TodoListBlockComponentWidget(
      key: context.node.key,
      node: context.node,
      padding: padding,
      textStyleBuilder: textStyleBuilder,
      icon: icon,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => (node) =>
      node.delta != null &&
      node.attributes.containsKey(
        TodoListBlockKeys.checked,
      );
}

class TodoListBlockComponentWidget extends StatefulWidget {
  const TodoListBlockComponentWidget({
    super.key,
    required this.node,
    this.padding = const EdgeInsets.all(0.0),
    this.textStyleBuilder,
    this.icon,
  });

  final Node node;
  final EdgeInsets padding;
  final TextStyle Function(bool checked)? textStyleBuilder;
  final Widget? Function(bool checked)? icon;

  @override
  State<TodoListBlockComponentWidget> createState() =>
      _TodoListBlockComponentWidgetState();
}

class _TodoListBlockComponentWidgetState
    extends State<TodoListBlockComponentWidget>
    with SelectableMixin, DefaultSelectable {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  late final editorState = Provider.of<EditorState>(context, listen: false);

  bool get checked => widget.node.attributes[TodoListBlockKeys.checked];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TodoListIcon(
            icon: widget.icon?.call(checked) ?? defaultCheckboxIcon(),
            onTap: checkOrUncheck,
          ),
          Flexible(
            child: FlowyRichText(
              key: forwardKey,
              node: widget.node,
              editorState: editorState,
              textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                widget.textStyleBuilder?.call(checked) ?? defaultTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkOrUncheck() async {
    final transaction = editorState.transaction
      ..updateNode(widget.node, {
        TodoListBlockKeys.checked: !checked,
      });
    return editorState.apply(transaction);
  }

  FlowySvg defaultCheckboxIcon() {
    return FlowySvg(
      width: 22,
      height: 22,
      padding: const EdgeInsets.only(right: 5.0),
      name: checked ? 'check' : 'uncheck',
    );
  }

  TextStyle? defaultTextStyle() {
    if (!checked) {
      return null;
    }
    return TextStyle(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey.shade400,
    );
  }
}

class _TodoListIcon extends StatelessWidget {
  const _TodoListIcon({
    required this.icon,
    required this.onTap,
  });

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
