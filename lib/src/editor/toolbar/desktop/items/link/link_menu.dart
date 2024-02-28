import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/overlay_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_validator/string_validator.dart';

class LinkMenu extends StatefulWidget {
  const LinkMenu({
    super.key,
    this.linkText,
    this.editorState,
    required this.onSubmitted,
    required this.onOpenLink,
    required this.onCopyLink,
    required this.onRemoveLink,
    required this.onDismiss,
  });

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
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (key) {
        if (key is KeyDownEvent &&
            key.logicalKey == LogicalKeyboardKey.escape) {
          widget.onDismiss();
        }
      },
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        focusNode: _focusNode,
        textAlign: TextAlign.left,
        controller: _textEditingController,
        onFieldSubmitted: widget.onSubmitted,
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
        validator: (value) {
          if (value == null || value.isEmpty || !isURL(value)) {
            return AppFlowyEditorL10n.current.incorrectLink;
          }
          return null;
        },
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
