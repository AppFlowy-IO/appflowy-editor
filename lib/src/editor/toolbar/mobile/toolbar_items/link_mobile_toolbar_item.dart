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

    return MobileLinkMenu(
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
      onCancel: () => itemMenuService.closeItemMenu(),
    );
  },
);

class MobileLinkMenu extends StatefulWidget {
  const MobileLinkMenu({
    super.key,
    this.linkText,
    required this.editorState,
    required this.onSubmitted,
    required this.onCancel,
  });

  final String? linkText;
  final EditorState editorState;
  final void Function(String) onSubmitted;
  final void Function() onCancel;

  @override
  State<MobileLinkMenu> createState() => _MobileLinkMenuState();
}

class _MobileLinkMenuState extends State<MobileLinkMenu> {
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
    const double spacing = 8;
    return Material(
      // TextField widget needs to be wrapped in a Material widget to provide a visual appearance
      color: style.backgroundColor,
      child: SizedBox(
        height: style.toolbarHeight * 2 + spacing,
        child: Column(
          children: [
            TextField(
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
            const SizedBox(height: spacing),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCancel.call();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        style.backgroundColor,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        style.primaryColor,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(style.borderRadius),
                        ),
                      ),
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(color: style.outlineColor),
                      ),
                    ),
                    child: Text(
                      AppFlowyEditorLocalizations.current.cancel,
                    ),
                  ),
                ),
                SizedBox(width: style.buttonSpacing),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSubmitted.call(_textEditingController.text);
                      widget.editorState.service.keyboardService
                          ?.closeKeyboard();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        style.primaryColor,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        style.onPrimaryColor,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(style.borderRadius),
                        ),
                      ),
                    ),
                    child: Text(
                      AppFlowyEditorLocalizations.current.done,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
