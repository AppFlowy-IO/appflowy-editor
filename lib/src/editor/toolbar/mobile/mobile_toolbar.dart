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
                child: _ToolbarItemListView(
                  editorState: widget.editorState,
                  selection: widget.selection,
                  toolbarItems: widget.toolbarItems,
                  itemOnPressed: (selectedItemIndex) {
                    setState(() {
                      _showItmeMenu = !_showItmeMenu;
                      _selectedToolbarItemIndex = selectedItemIndex;
                    });
                  },
                ),
              ),
              _CloseKeyboardBtn(widget.editorState),
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

class _CloseKeyboardBtn extends StatelessWidget {
  const _CloseKeyboardBtn(this.editorState);

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: () {
          // clear selection to close keyboard and toolbar
          editorState.selectionService.updateSelection(null);
        },
        icon: const Icon(Icons.keyboard_hide),
      ),
    );
  }
}

class _ToolbarItemListView extends StatelessWidget {
  const _ToolbarItemListView({
    Key? key,
    required this.itemOnPressed,
    required this.toolbarItems,
    required this.editorState,
    required this.selection,
  }) : super(key: key);

  final Function(int index) itemOnPressed;
  final List<MobileToolbarItem> toolbarItems;
  final EditorState editorState;
  final Selection selection;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final toobarItem = toolbarItems[index];
        return Material(
          color: Colors.transparent,
          child: IconButton(
            icon: toobarItem.itemIcon,
            onPressed: () {
              if (toobarItem.hasMenu) {
                // open /close current item menu through its parent widget(MobileToolbarWidget)
                itemOnPressed.call(index);
              } else {
                toolbarItems[index].actionHandler!(
                  editorState,
                  selection,
                );
              }
            },
          ),
        );
      },
      itemCount: toolbarItems.length,
      scrollDirection: Axis.horizontal,
    );
  }
}
