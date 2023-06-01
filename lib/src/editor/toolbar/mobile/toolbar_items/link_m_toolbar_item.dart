import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final linkMToolbarItem = MToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(
    afMobileIcons: AFMobileIcons.link,
  ),
  itemMenuBuilder: (editorState, selection) {
    final String? linkText = editorState.getDeltaAttributeValueInSelection(
      BuiltInAttributeKey.href,
      selection,
    );

    return MLinkMenu(
      editorState: editorState,
      linkText: linkText,
      onSubmitted: (value) async {
        await editorState.formatDelta(selection, {
          BuiltInAttributeKey.href: value,
        });
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
  State<MLinkMenu> createState() => _MLinkMenuState();
}

class _MLinkMenuState extends State<MLinkMenu> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MSize.rowHeight,
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
                cursorColor: MColors.toolbarTextColor,
                decoration: InputDecoration(
                  hintText: 'URL',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(MSize.boarderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: MColors.toolbarItemOutlineColor,
                    ),
                    borderRadius: BorderRadius.circular(MSize.boarderRadius),
                  ),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: MColors.toolbarTextColor,
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
                //TODO(yijing): close menu
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  MColors.toolbarItemHightlightColor,
                ),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MSize.boarderRadius),
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
