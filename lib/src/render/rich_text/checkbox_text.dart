import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/rich_text/built_in_text_widget.dart';

import 'package:flutter/material.dart';
import 'package:appflowy_editor/src/extensions/theme_extension.dart';

class CheckboxNodeWidgetBuilder extends NodeWidgetBuilder<TextNode> {
  @override
  Widget build(NodeWidgetContext<TextNode> context) {
    return CheckboxNodeWidget(
      key: context.node.key,
      textNode: context.node,
      editorState: context.editorState,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => ((node) {
        return node.attributes.containsKey(BuiltInAttributeKey.checkbox);
      });
}

class CheckboxNodeWidget extends BuiltInTextWidget {
  const CheckboxNodeWidget({
    Key? key,
    required this.textNode,
    required this.editorState,
  }) : super(key: key);

  @override
  final TextNode textNode;
  @override
  final EditorState editorState;

  @override
  State<CheckboxNodeWidget> createState() => _CheckboxNodeWidgetState();
}

class _CheckboxNodeWidgetState extends State<CheckboxNodeWidget>
    with SelectableMixin, DefaultSelectable, BuiltInTextWidgetMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'checkbox_text');
  @override
  GlobalKey<State<StatefulWidget>> get containerKey =>
      throw UnimplementedError();
  CheckboxPluginStyle get style =>
      Theme.of(context).extensionOrNull<CheckboxPluginStyle>() ??
      CheckboxPluginStyle.light;

  EdgeInsets get padding => style.padding(
        widget.editorState,
        widget.textNode,
      );

  TextStyle get textStyle => style.textStyle(
        widget.editorState,
        widget.textNode,
      );

  Widget get icon => style.icon(
        widget.editorState,
        widget.textNode,
      );

  @override
  Widget buildWithSingle(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // await widget.editorState.formatTextToCheckbox(
              //   !check,
              //   textNode: widget.textNode,
              // );
            },
            child: icon,
          ),
          Flexible(
            child: FlowyRichText(
              key: forwardKey,
              placeholderText: 'To-do',
              lineHeight: widget.editorState.editorStyle.lineHeight,
              node: widget.textNode,
              textSpanDecorator: (textSpan) =>
                  textSpan.updateTextStyle(textStyle),
              placeholderTextSpanDecorator: (textSpan) =>
                  textSpan.updateTextStyle(textStyle),
              editorState: widget.editorState,
            ),
          ),
        ],
      ),
    );
  }
}
