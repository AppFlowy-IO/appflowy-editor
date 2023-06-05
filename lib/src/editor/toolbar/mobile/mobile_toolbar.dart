import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileToolbar extends StatelessWidget {
  const MobileToolbar({
    super.key,
    required this.editorState,
    required this.toolbarItems,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Selection?>(
      valueListenable: editorState.service.selectionService.currentSelection,
      builder: (_, Selection? selection, __) {
        if (selection == null) {
          return const SizedBox.shrink();
        }
        return MobileToolbarWidget(
          // Use selection as key to force rebuild toolbar widget when selection changed.
          key: ValueKey(selection),
          editorState: editorState,
          selection: selection,
          toolbarItems: toolbarItems,
        );
      },
    );
  }
}

class MobileToolbarWidget extends StatefulWidget {
  const MobileToolbarWidget({
    super.key,
    required this.editorState,
    required this.toolbarItems,
    required this.selection,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  final Selection selection;

  @override
  State<MobileToolbarWidget> createState() => _MobileToolbarWidgetState();
}

class _MobileToolbarWidgetState extends State<MobileToolbarWidget> {
  late bool _showItmeMenu;
  int? _selectedToolbarItemIndex;

  @override
  void initState() {
    super.initState();
    _showItmeMenu = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // toolbar
        Container(
          width: width,
          height: MSize.rowHeight,
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
                          } else {
                            widget.toolbarItems[index].actionHandler!(
                              widget.editorState,
                              widget.selection,
                            );
                          }
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
                    widget.editorState.selectionService.updateSelection(null);
                  },
                  icon: const Icon(Icons.keyboard_hide),
                ),
              ),
            ],
          ),
        ),
        // only for MobileToolbarItem.withMenu
        _showItmeMenu
            ? MobileToolbarItemMenu(
                key: mobileToolbarItemMenuStateKey,
                editorState: widget.editorState,
                itemMenu: widget.toolbarItems[_selectedToolbarItemIndex!]
                    .itemMenuBuilder!(widget.editorState, widget.selection),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
