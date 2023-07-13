import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final linkMobileToolbarItem = MobileToolbarItem.withMenu(
  itemIcon: const AFMobileIcon(
    afMobileIcons: AFMobileIcons.link,
  ),
  itemMenuBuilder: (editorState, selection, itemMenuService) {
    final String? linkText = editorState.getDeltaAttributeValueInSelection(
      AppFlowyRichTextKeys.href,
      selection,
    );

    return _MobileLinkMenu(
      editorState: editorState,
      linkText: linkText,
      onSubmitted: (value) async {
        if (value.isNotEmpty) {
          await editorState.formatDelta(selection, {
            AppFlowyRichTextKeys.href: value,
          });
        }
        itemMenuService.closeItemMenu();
        editorState.service.keyboardService?.closeKeyboard();
      },
    );
  },
);

class _MobileLinkMenu extends StatefulWidget {
  const _MobileLinkMenu({
    this.linkText,
    required this.editorState,
    required this.onSubmitted,
  });

  final String? linkText;
  final EditorState editorState;
  final void Function(String) onSubmitted;

  @override
  State<_MobileLinkMenu> createState() => _MobileLinkMenuState();
}

class _MobileLinkMenuState extends State<_MobileLinkMenu> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    widget.editorState.service.keyboardService?.disable();
    _textEditingController = TextEditingController(text: widget.linkText ?? '');
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    widget.editorState.service.keyboardService?.enable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarStyle.of(context);
    return Material(
      // TextField widget needs to be wrapped in a Material widget to provide a visual appearance
      color: style.backgroundColor,
      child: SizedBox(
        height: style.toolbarHeight,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  autofocus: true,
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
                  // TODO(yijing):  refresh toolbar to remove _QuitEditingBtn
                  widget.onSubmitted.call(_textEditingController.text);
                  widget.editorState.service.keyboardService?.closeKeyboard();
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
                child: Text(AppFlowyEditorLocalizations.current.done),
              ),
            )
            // TODO(yijing): edit link?
          ],
        ),
      ),
    );
  }
}
