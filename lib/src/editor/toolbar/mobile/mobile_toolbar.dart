import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatefulWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
    required this.toolbarItems,
  });

  final EditorState editorState;
  final List<MToolbarItem> toolbarItems;

  @override
  State<MobileToolbar> createState() => _MobileToolbarState();
}

class _MobileToolbarState extends State<MobileToolbar> {
  bool _showItmeMenu = false;
  int? _selectedToolbarItemIndex;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<Selection?>(
      valueListenable:
          widget.editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        } else {
          return Column(
            children: [
              Container(
                width: width,
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: MColors.toolbarItemOutlineColor),
                    bottom: BorderSide(color: MColors.toolbarItemOutlineColor),
                  ),
                  color: MColors.toolbarBgColor,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final toobarItem = widget.toolbarItems[index];
                          return Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: toobarItem.itemIcon,
                              onPressed: () {
                                if (toobarItem.hasMenu) {
                                  setState(() {
                                    _showItmeMenu = !_showItmeMenu;
                                    _selectedToolbarItemIndex = index;
                                  });
                                }
                                //execute command
                                // TODO(yijing): add MToolbarItem.action feature
                              },
                            ),
                          );
                        },
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
              // only for MToolbarItem.withMenu
              _showItmeMenu
                  ? MToolbarItemMenu(
                      editorState: widget.editorState,
                      itemMenu: widget.toolbarItems[_selectedToolbarItemIndex!]
                          .itemMenuBuilder!(widget.editorState, selection),
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }
}
