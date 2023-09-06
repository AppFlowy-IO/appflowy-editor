import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SelectionMenuItemHandler = void Function(
  EditorState editorState,
  SelectionMenuService menuService,
  BuildContext context,
);

/// Selection Menu Item
class SelectionMenuItem {
  SelectionMenuItem({
    required this.name,
    required this.icon,
    required this.keywords,
    required SelectionMenuItemHandler handler,
  }) {
    this.handler = (editorState, menuService, context) {
      if (deleteSlash) {
        _deleteSlash(editorState);
      }
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      handler(editorState, menuService, context);
      onSelected?.call();
      // });
    };
  }

  final String name;
  final Widget Function(
    EditorState editorState,
    bool onSelected,
    SelectionMenuStyle style,
  ) icon;

  /// Customizes keywords for item.
  ///
  /// The keywords are used to quickly retrieve items.
  final List<String> keywords;
  late final SelectionMenuItemHandler handler;

  VoidCallback? onSelected;

  bool deleteSlash = true;

  void _deleteSlash(EditorState editorState) {
    final selection = editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = editorState.getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }
    final end = selection.start.offset;
    final lastSlashIndex =
        delta.toPlainText().substring(0, end).lastIndexOf('/');
    // delete all the texts after '/' along with '/'
    final transaction = editorState.transaction
      ..deleteText(
        node,
        lastSlashIndex,
        end - lastSlashIndex,
      );

    editorState.apply(transaction);
  }

  /// Creates a selection menu entry for inserting a [Node].
  /// [name] and [iconData] define the appearance within the selection menu.
  ///
  /// The insert position is determined by the result of [replace] and
  /// [insertBefore]
  /// If no values are provided for [replace] and [insertBefore] the node is
  /// inserted after the current selection.
  /// [replace] takes precedence over [insertBefore]
  ///
  /// [updateSelection] can be used to update the selection after the node
  /// has been inserted.
  factory SelectionMenuItem.node({
    required String name,
    required IconData iconData,
    required List<String> keywords,
    required Node Function(EditorState editorState, BuildContext context)
        nodeBuilder,
    bool Function(EditorState editorState, Node node)? insertBefore,
    bool Function(EditorState editorState, Node node)? replace,
    Selection? Function(
      EditorState editorState,
      Path insertPath,
      bool replaced,
      bool insertedBefore,
    )? updateSelection,
  }) {
    return SelectionMenuItem(
      name: name,
      icon: (editorState, onSelected, style) => Icon(
        iconData,
        color: onSelected
            ? style.selectionMenuItemSelectedIconColor
            : style.selectionMenuItemIconColor,
        size: 18.0,
      ),
      keywords: keywords,
      handler: (editorState, _, context) {
        final selection = editorState.selection;
        if (selection == null || !selection.isCollapsed) {
          return;
        }
        final node = editorState.getNodeAtPath(selection.end.path);
        final delta = node?.delta;
        if (node == null || delta == null) {
          return;
        }
        final newNode = nodeBuilder(editorState, context);
        final transaction = editorState.transaction;
        final bReplace = replace?.call(editorState, node) ?? false;
        final bInsertBefore = insertBefore?.call(editorState, node) ?? false;

        //default insert after
        var path = node.path.next;
        if (bReplace) {
          path = node.path;
        } else if (bInsertBefore) {
          path = node.path;
        }

        transaction
          ..insertNode(path, newNode)
          ..afterSelection = updateSelection?.call(
                editorState,
                path,
                bReplace,
                bInsertBefore,
              ) ??
              selection;

        if (bReplace) {
          transaction.deleteNode(node);
        }

        editorState.apply(transaction);
      },
    );
  }
}

class SelectionMenuStyle {
  const SelectionMenuStyle({
    required this.selectionMenuBackgroundColor,
    required this.selectionMenuItemTextColor,
    required this.selectionMenuItemIconColor,
    required this.selectionMenuItemSelectedTextColor,
    required this.selectionMenuItemSelectedIconColor,
    required this.selectionMenuItemSelectedColor,
  });

  static const light = SelectionMenuStyle(
    selectionMenuBackgroundColor: Color(0xFFFFFFFF),
    selectionMenuItemTextColor: Color(0xFF333333),
    selectionMenuItemIconColor: Color(0xFF333333),
    selectionMenuItemSelectedTextColor: Color.fromARGB(255, 56, 91, 247),
    selectionMenuItemSelectedIconColor: Color.fromARGB(255, 56, 91, 247),
    selectionMenuItemSelectedColor: Color(0xFFE0F8FF),
  );

  static const dark = SelectionMenuStyle(
    selectionMenuBackgroundColor: Color(0xFF282E3A),
    selectionMenuItemTextColor: Color(0xFFBBC3CD),
    selectionMenuItemIconColor: Color(0xFFBBC3CD),
    selectionMenuItemSelectedTextColor: Color(0xFF131720),
    selectionMenuItemSelectedIconColor: Color(0xFF131720),
    selectionMenuItemSelectedColor: Color(0xFF00BCF0),
  );

  final Color selectionMenuBackgroundColor;
  final Color selectionMenuItemTextColor;
  final Color selectionMenuItemIconColor;
  final Color selectionMenuItemSelectedTextColor;
  final Color selectionMenuItemSelectedIconColor;
  final Color selectionMenuItemSelectedColor;
}

class SelectionMenuWidget extends StatefulWidget {
  const SelectionMenuWidget({
    Key? key,
    required this.items,
    required this.maxItemInRow,
    required this.editorState,
    required this.menuService,
    required this.onExit,
    required this.onSelectionUpdate,
    required this.selectionMenuStyle,
    required this.itemCountFilter,
    required this.deleteSlashByDefault,
  }) : super(key: key);

  final List<SelectionMenuItem> items;
  final int itemCountFilter;
  final int maxItemInRow;

  final SelectionMenuService menuService;
  final EditorState editorState;

  final VoidCallback onSelectionUpdate;
  final VoidCallback onExit;

  final SelectionMenuStyle selectionMenuStyle;

  final bool deleteSlashByDefault;

  @override
  State<SelectionMenuWidget> createState() => _SelectionMenuWidgetState();
}

class _SelectionMenuWidgetState extends State<SelectionMenuWidget> {
  final _focusNode = FocusNode(debugLabel: 'popup_list_widget');

  int _selectedIndex = 0;
  List<SelectionMenuItem> _showingItems = [];

  int _searchCounter = 0;

  String _keyword = '';
  String get keyword => _keyword;
  set keyword(String newKeyword) {
    _keyword = newKeyword;

    // Search items according to the keyword, and calculate the length of
    //  the longest keyword, which is used to dismiss the selection_service.
    var maxKeywordLength = 0;
    final items = widget.items
        .where(
          (item) => item.keywords.any((keyword) {
            final value = keyword.contains(newKeyword.toLowerCase());
            if (value) {
              maxKeywordLength = max(maxKeywordLength, keyword.length);
            }
            return value;
          }),
        )
        .toList(growable: false);

    Log.ui.debug('$items');

    if (keyword.length >= maxKeywordLength + 2 &&
        !(widget.deleteSlashByDefault && _searchCounter < 2)) {
      return widget.onExit();
    }
    setState(() {
      _showingItems = items;
    });

    if (_showingItems.isEmpty) {
      _searchCounter++;
    } else {
      _searchCounter = 0;
    }
  }

  @override
  void initState() {
    super.initState();

    _showingItems = widget.items;

    keepEditorFocusNotifier.value += 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    keepEditorFocusNotifier.value -= 1;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: _onKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.selectionMenuStyle.selectionMenuBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: _showingItems.isEmpty
            ? _buildNoResultsWidget(context)
            : _buildResultsWidget(
                context,
                _showingItems,
                widget.itemCountFilter,
                _selectedIndex,
              ),
      ),
    );
  }

  Widget _buildResultsWidget(
    BuildContext buildContext,
    List<SelectionMenuItem> items,
    int itemCountFilter,
    int selectedIndex,
  ) {
    List<Widget> columns = [];
    List<Widget> itemWidgets = [];

    // apply item count filter

    if (itemCountFilter > 0) {
      items = items.take(itemCountFilter).toList();
    }

    for (var i = 0; i < items.length; i++) {
      if (i != 0 && i % (widget.maxItemInRow) == 0) {
        columns.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: itemWidgets,
          ),
        );
        itemWidgets = [];
      }
      itemWidgets.add(
        SelectionMenuItemWidget(
          item: items[i],
          isSelected: selectedIndex == i,
          editorState: widget.editorState,
          menuService: widget.menuService,
          selectionMenuStyle: widget.selectionMenuStyle,
        ),
      );
    }
    if (itemWidgets.isNotEmpty) {
      columns.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: itemWidgets,
        ),
      );
      itemWidgets = [];
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }

  Widget _buildNoResultsWidget(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Material(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'No results',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Handles arrow keys to switch selected items
  /// Handles keyword searches
  /// Handles enter to select item and esc to exit
  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    Log.keyboard.debug('slash command, on key $event');
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final arrowKeys = [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
    ];

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (0 <= _selectedIndex && _selectedIndex < _showingItems.length) {
        _showingItems[_selectedIndex]
            .handler(widget.editorState, widget.menuService, context);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onExit();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_searchCounter > 0) {
        _searchCounter--;
      }
      if (keyword.isEmpty) {
        widget.onExit();
      } else {
        keyword = keyword.substring(0, keyword.length - 1);
      }
      _deleteLastCharacters();
      return KeyEventResult.handled;
    } else if (event.character != null &&
        !arrowKeys.contains(event.logicalKey) &&
        event.logicalKey != LogicalKeyboardKey.tab) {
      keyword += event.character!;
      _insertText(event.character!);
      return KeyEventResult.handled;
    }

    var newSelectedIndex = _selectedIndex;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      newSelectedIndex -= widget.maxItemInRow;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      newSelectedIndex += widget.maxItemInRow;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      newSelectedIndex -= 1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      newSelectedIndex += 1;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      newSelectedIndex += widget.maxItemInRow;
      var currRow = (newSelectedIndex) % widget.maxItemInRow;
      if (newSelectedIndex >= _showingItems.length) {
        newSelectedIndex = (currRow + 1) % widget.maxItemInRow;
      }
    }

    if (newSelectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newSelectedIndex.clamp(0, _showingItems.length - 1);
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _deleteLastCharacters({int length = 1}) {
    final selection = widget.editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = widget.editorState.getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }

    widget.onSelectionUpdate();
    final transaction = widget.editorState.transaction
      ..deleteText(
        node,
        selection.start.offset - length,
        length,
      );
    widget.editorState.apply(transaction);
  }

  void _insertText(String text) {
    final selection = widget.editorState.selection;
    if (selection == null || !selection.isSingle) {
      return;
    }
    final node = widget.editorState.getNodeAtPath(selection.end.path);
    if (node == null) {
      return;
    }
    widget.onSelectionUpdate();
    final transaction = widget.editorState.transaction
      ..insertText(
        node,
        selection.end.offset,
        text,
      );
    widget.editorState.apply(transaction);
  }
}
