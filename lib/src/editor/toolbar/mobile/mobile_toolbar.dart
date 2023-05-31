import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatefulWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
    required this.toolbarItems,
  });

  final EditorState editorState;
  final List<Widget> toolbarItems;

  @override
  State<MobileToolbar> createState() => _MobileToolbarState();
}

class _MobileToolbarState extends State<MobileToolbar> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<Selection?>(
      valueListenable:
          widget.editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        return selection == null
            // hide toolbar
            ? const SizedBox.shrink()
            : Column(
                children: [
                  Container(
                    width: width,
                    height: 50,
                    // TODO(yijing): expose background color in editor style
                    color: const Color(0xFFF1F1F4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) =>
                                widget.toolbarItems[index],
                            itemCount: widget.toolbarItems.length,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                        // close keyboard button
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: () {
                              // clear selection to close toolbar
                              widget.editorState.selectionService
                                  .updateSelection(null);
                            },
                            icon: const Icon(Icons.keyboard_hide),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // show menu when toolbar item is clicked
                  // Container(
                  //   width: width,
                  //   child: Text('menu'),
                  //   color: const Color(0xFFE0E0E0),
                  // )
                ],
              );
      },
    );
  }
}
