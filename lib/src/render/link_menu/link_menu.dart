import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/render/style/editor_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkMenu extends StatefulWidget {
  const LinkMenu({
    Key? key,
    this.linkText,
    this.editorState,
    required this.onSubmitted,
    required this.onOpenLink,
    required this.onCopyLink,
    required this.onRemoveLink,
    required this.onFocusChange,
    required this.onDismiss,
  }) : super(key: key);

  final String? linkText;
  final EditorState? editorState;
  final void Function(String text) onSubmitted;
  final VoidCallback onOpenLink;
  final VoidCallback onCopyLink;
  final VoidCallback onRemoveLink;
  final VoidCallback onDismiss;
  final void Function(bool value) onFocusChange;

  @override
  State<LinkMenu> createState() => _LinkMenuState();
}

class _LinkMenuState extends State<LinkMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  EditorStyle? get style => widget.editorState?.editorStyle;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.linkText ?? '';
    _focusNode.requestFocus();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style?.selectionMenuBackgroundColor ?? Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 16.0),
              _buildInput(),
              const SizedBox(height: 16.0),
              if (widget.linkText != null) ...[
                _buildIconButton(
                  iconName: 'link',
                  color: style?.popupMenuFGColor,
                  text: 'Open link',
                  onPressed: widget.onOpenLink,
                ),
                _buildIconButton(
                  iconName: 'copy',
                  color: style?.popupMenuFGColor,
                  text: 'Copy link',
                  onPressed: widget.onCopyLink,
                ),
                _buildIconButton(
                  iconName: 'delete',
                  color: style?.popupMenuFGColor,
                  text: 'Remove link',
                  onPressed: widget.onRemoveLink,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Add your link',
      style: TextStyle(
        fontSize: style?.textStyle?.fontSize,
      ),
    );
  }

  Widget _buildInput() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      child: TextField(
        focusNode: _focusNode,
        style: TextStyle(
          fontSize: style?.textStyle?.fontSize,
        ),
        textAlign: TextAlign.left,
        controller: _textEditingController,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: 'URL',
          hintStyle: TextStyle(
            fontSize: style?.textStyle?.fontSize,
          ),
          contentPadding: const EdgeInsets.all(16.0),
          isDense: true,
          suffixIcon: IconButton(
            padding: const EdgeInsets.all(4.0),
            icon: const FlowySvg(
              name: 'clear',
              width: 24,
              height: 24,
            ),
            onPressed: _textEditingController.clear,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Color(0xFFBDBDBD)),
          ),
        ),
      ),
      onKey: (key) {
        if (key is! RawKeyDownEvent) return;
        if (key.logicalKey == LogicalKeyboardKey.escape) {
          widget.onDismiss();
        }
      },
    );
  }

  Widget _buildIconButton({
    required String iconName,
    Color? color,
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: FlowySvg(
        name: iconName,
        color: color,
      ),
      label: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: color,
          fontSize: 14.0,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return style!.popupMenuHoverColor!;
            }
            return Colors.transparent;
          },
        ),
      ),
      onPressed: onPressed,
    );
  }

  void _onFocusChange() {
    widget.onFocusChange(_focusNode.hasFocus);
  }
}
