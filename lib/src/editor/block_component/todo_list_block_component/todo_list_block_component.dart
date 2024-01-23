import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_icon_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TodoListBlockKeys {
  const TodoListBlockKeys._();

  static const String type = 'todo_list';

  /// The checked data of a todo list block.
  ///
  /// The value is a boolean.
  static const String checked = 'checked';

  static const String delta = blockComponentDelta;

  static const String backgroundColor = blockComponentBackgroundColor;

  static const String textDirection = blockComponentTextDirection;
}

Node todoListNode({
  required bool checked,
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: TodoListBlockKeys.type,
    attributes: {
      ...attributes,
      TodoListBlockKeys.checked: checked,
      if (textDirection != null) TodoListBlockKeys.textDirection: textDirection,
    },
    children: children ?? [],
  );
}

class TodoListBlockComponentBuilder extends BlockComponentBuilder {
  TodoListBlockComponentBuilder({
    super.configuration,
    this.textStyleBuilder,
    this.iconBuilder,
    this.toggleChildrenTriggers,
  });

  /// The text style of the todo list block.
  final TextStyle Function(bool checked)? textStyleBuilder;

  final BlockIconBuilder? iconBuilder;

  final List<LogicalKeyboardKey>? toggleChildrenTriggers;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return TodoListBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      textStyleBuilder: textStyleBuilder,
      iconBuilder: iconBuilder,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
      toggleChildrenTriggers: toggleChildrenTriggers,
    );
  }

  @override
  bool validate(Node node) {
    return node.delta != null &&
        node.attributes[TodoListBlockKeys.checked] is bool;
  }
}

class TodoListBlockComponentWidget extends BlockComponentStatefulWidget {
  const TodoListBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.textStyleBuilder,
    this.iconBuilder,
    this.toggleChildrenTriggers,
  });

  final TextStyle Function(bool checked)? textStyleBuilder;
  final BlockIconBuilder? iconBuilder;
  final List<LogicalKeyboardKey>? toggleChildrenTriggers;

  @override
  State<TodoListBlockComponentWidget> createState() =>
      _TodoListBlockComponentWidgetState();
}

class _TodoListBlockComponentWidgetState
    extends State<TodoListBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        NestedBlockComponentStatefulWidgetMixin,
        BlockComponentTextDirectionMixin,
        BlockComponentAlignMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: TodoListBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  bool get checked => widget.node.attributes[TodoListBlockKeys.checked];

  CursorStyle _cursorStyle = CursorStyle.verticalLine;

  @override
  CursorStyle get cursorStyle => _cursorStyle;

  set cursorStyle(CursorStyle cursorStyle) {
    _cursorStyle = cursorStyle;
  }

  bool _shouldCursorBlink = true;

  @override
  bool get shouldCursorBlink => _shouldCursorBlink;

  set shouldCursorBlink(bool value) {
    _shouldCursorBlink = value;
  }

  void _onCursorStyleChange() {
    cursorStyle = editorState.cursorStyle;

    shouldCursorBlink = cursorStyle != CursorStyle.dottedVerticalLine;
  }

  @override
  void initState() {
    super.initState();
    editorState.cursorStyleNotifier.addListener(_onCursorStyleChange);
  }

  @override
  void dispose() {
    editorState.cursorStyleNotifier.removeListener(_onCursorStyleChange);
    super.dispose();
  }

  @override
  Widget buildComponent(
    BuildContext context, {
    bool withBackgroundColor = true,
  }) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = Container(
      width: double.infinity,
      alignment: alignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          widget.iconBuilder != null
              ? widget.iconBuilder!(context, node)
              : _TodoListIcon(
                  checked: checked,
                  onTap: checkOrUncheck,
                ),
          Flexible(
            child: AppFlowyRichText(
              key: forwardKey,
              delegate: this,
              node: widget.node,
              editorState: editorState,
              textAlign: alignment?.toTextAlign,
              placeholderText: placeholderText,
              textDirection: textDirection,
              textSpanDecorator: (textSpan) =>
                  textSpan.updateTextStyle(textStyle).updateTextStyle(
                        widget.textStyleBuilder?.call(checked) ??
                            defaultTextStyle(),
                      ),
              placeholderTextSpanDecorator: (textSpan) =>
                  textSpan.updateTextStyle(
                placeholderTextStyle,
              ),
              cursorColor: editorState.editorStyle.cursorColor,
              selectionColor: editorState.editorStyle.selectionColor,
              cursorWidth: editorState.editorStyle.cursorWidth,
            ),
          ),
        ],
      ),
    );

    child = Container(
      color: withBackgroundColor ? backgroundColor : null,
      child: Padding(
        key: blockComponentKey,
        padding: padding,
        child: child,
      ),
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      dragAndDropListenable: editorState.dragAndDropSelectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  void checkOrUncheck() {
    final transaction = editorState.transaction
      ..updateNode(widget.node, {
        TodoListBlockKeys.checked: !checked,
      });

    if (widget.toggleChildrenTriggers != null &&
        RawKeyboard.instance.keysPressed.any(
          (element) => widget.toggleChildrenTriggers!.contains(element),
        )) {
      checkOrUncheckChildren(!checked, widget.node);
    }

    editorState.apply(transaction, withUpdateSelection: false);
  }

  void checkOrUncheckChildren(
    bool checked,
    Node node,
  ) {
    for (final child in node.children) {
      if (child.children.isNotEmpty) {
        checkOrUncheckChildren(checked, child);
      }

      if (child.type == TodoListBlockKeys.type) {
        final transaction = editorState.transaction
          ..updateNode(child, {
            TodoListBlockKeys.checked: checked,
          });

        editorState.apply(transaction);
      }
    }
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
    required this.onTap,
    required this.checked,
  });

  final VoidCallback onTap;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 26, minHeight: 22),
          padding: const EdgeInsets.only(right: 4.0),
          child: EditorSvg(
            width: 22,
            height: 22,
            name: checked ? 'check' : 'uncheck',
          ),
        ),
      ),
    );
  }
}
