import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/overlay_util.dart';
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
    required this.onDismiss,
  }) : super(key: key);

  final String? linkText;
  final EditorState? editorState;
  final void Function(String text) onSubmitted;
  final VoidCallback onOpenLink;
  final VoidCallback onCopyLink;
  final VoidCallback onRemoveLink;
  final VoidCallback onDismiss;

  @override
  State<LinkMenu> createState() => _LinkMenuState();
}

class _LinkMenuState extends State<LinkMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.linkText ?? '';
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: buildOverlayDecoration(context),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorOverlayTitle(
            text: AppFlowyEditorL10n.current.addYourLink,
          ),
          const SizedBox(height: 16.0),
          _buildInput(),
          const SizedBox(height: 16.0),
          if (widget.linkText != null) ...[
            _buildIconButton(
              iconName: 'link',
              text: AppFlowyEditorL10n.current.openLink,
              onPressed: widget.onOpenLink,
            ),
            _buildIconButton(
              iconName: 'copy',
              text: AppFlowyEditorL10n.current.copyLink,
              onPressed: widget.onCopyLink,
            ),
            _buildIconButton(
              iconName: 'delete',
              text: AppFlowyEditorL10n.current.removeLink,
              onPressed: widget.onRemoveLink,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInput() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (key) {
        if (key is RawKeyDownEvent &&
            key.logicalKey == LogicalKeyboardKey.escape) {
          widget.onDismiss();
        }
      },
      child: TextField(
        focusNode: _focusNode,
        textAlign: TextAlign.left,
        controller: _textEditingController,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: AppFlowyEditorL10n.current.urlHint,
          contentPadding: const EdgeInsets.all(16.0),
          isDense: true,
          suffixIcon: IconButton(
            padding: const EdgeInsets.all(4.0),
            icon: const EditorSvg(
              name: 'clear',
              width: 24,
              height: 24,
            ),
            onPressed: _textEditingController.clear,
            splashRadius: 5,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String iconName,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        icon: EditorSvg(
          name: iconName,
          color: Theme.of(context).textTheme.labelLarge?.color,
        ),
        label: Row(
          // This row is used to align the text to the left
          children: [
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.labelLarge?.color,
              ),
            ),
          ],
        ),
        style: buildOverlayButtonStyle(context),
        onPressed: onPressed,
      ),
    );
  }
}
