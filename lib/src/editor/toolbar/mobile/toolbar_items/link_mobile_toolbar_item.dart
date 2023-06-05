import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final linkMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(
    afMobileIcons: AFMobileIcons.link,
  ),
  itemMenuBuilder: (editorState, selection) {
    final String? linkText = editorState.getDeltaAttributeValueInSelection(
      FlowyRichTextKeys.href,
      selection,
    );

    return MLinkMenu(
      editorState: editorState,
      linkText: linkText,
      onSubmitted: (value) async {
        await editorState.formatDelta(selection, {
          FlowyRichTextKeys.href: value,
        });
        mobileToolbarItemMenuStateKey.currentState?.closeItemMenu();
      },
    );
  },
);

class MLinkMenu extends StatefulWidget {
  const MLinkMenu({
    super.key,
    required this.editorState,
    this.linkText,
    required this.onSubmitted,
  });

  final EditorState editorState;
  final String? linkText;
  final void Function(String) onSubmitted;

  @override
  State<MLinkMenu> createState() => MLinkMenuState();
}

class MLinkMenuState extends State<MLinkMenu> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController.text = widget.linkText ?? '';
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    return SizedBox(
      height: style.toolbarHeight,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                focusNode: _focusNode,
                controller: _textEditingController,
                keyboardType: TextInputType.url,
                onSubmitted: widget.onSubmitted,
                cursorColor: style.foregroundColor,
                decoration: InputDecoration(
                  hintText: 'URL',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: style.itemOutlineColor,
                    ),
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: style.itemOutlineColor,
                    ),
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      Icons.clear_rounded,
                      color: style.foregroundColor,
                    ),
                    onPressed: _textEditingController.clear,
                    splashRadius: 5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                widget.onSubmitted.call(_textEditingController.text);
                mobileToolbarItemMenuStateKey.currentState?.closeItemMenu();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  style.itemHighlightColor,
                ),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                ),
              ),
              child: const Text('Done'),
            ),
          )
          // TODO(yijing): edit link?
        ],
      ),
    );
  }
}
