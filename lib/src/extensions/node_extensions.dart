import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

extension NodeExtensions on Node {
  RenderBox? get renderBox =>
      key.currentContext?.findRenderObject()?.unwrapOrNull<RenderBox>();

  BuildContext? get context => key.currentContext;
  SelectableMixin? get selectable =>
      key.currentState?.unwrapOrNull<SelectableMixin>();

  /// Level of the node in the document tree.
  ///
  /// The root node has a level of 0.
  int get level {
    var level = 0;
    var parent = this.parent;
    while (parent != null) {
      level++;
      parent = parent.parent;
    }
    return level;
  }

  bool inSelection(Selection selection) {
    if (selection.start.path <= selection.end.path) {
      return selection.start.path <= path && path <= selection.end.path;
    } else {
      return selection.end.path <= path && path <= selection.start.path;
    }
  }

  Rect get rect {
    if (renderBox != null) {
      final boxOffset = renderBox!.localToGlobal(Offset.zero);
      return boxOffset & renderBox!.size;
    }
    return Rect.zero;
  }

  /// Returns the first previous node in the subtree that satisfies the given predicate
  Node? previousNodeWhere(bool Function(Node element) test) {
    var previous = this.previous;
    while (previous != null) {
      final last = previous.lastChildWhere(test);
      if (last != null) {
        return last;
      }
      if (test(previous)) {
        return previous;
      }
      previous = previous.previous;
    }
    final parent = this.parent;
    if (parent != null) {
      if (test(parent)) {
        return parent;
      }
      return parent.previousNodeWhere(test);
    }
    return null;
  }

  /// Returns the last node in the subtree that satisfies the given predicate
  Node? lastChildWhere(bool Function(Node element) test) {
    final children = this.children.toList().reversed;
    for (final child in children) {
      if (child.children.isNotEmpty) {
        final last = child.lastChildWhere(test);
        if (last != null) {
          return last;
        }
      }
      if (test(child)) {
        return child;
      }
    }
    return null;
  }

  // find the node from it's children or it's next sibling to find the node that matches the given predicate
  Node? findDownward(bool Function(Node element) test) {
    final children = this.children.toList();
    for (final child in children) {
      if (test(child)) {
        return child;
      }
      if (child.children.isNotEmpty) {
        final node = child.findDownward(test);
        if (node != null) {
          return node;
        }
      }
    }
    final next = this.next;
    if (next != null) {
      if (test(next)) {
        return next;
      }
      return next.findDownward(test);
    }
    return null;
  }

  bool allSatisfyInSelection(
    Selection selection,
    bool Function(Delta delta) test,
  ) {
    if (selection.isCollapsed) {
      return false;
    }

    selection = selection.normalized;

    var delta = this.delta;
    if (delta == null) {
      return false;
    }

    delta = delta.slice(selection.startIndex, selection.endIndex);

    return test(delta);
  }

  bool isParentOf(Node node) {
    var parent = node.parent;
    while (parent != null) {
      if (parent.id == id) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  Node? findParent(bool Function(Node element) test) {
    if (test(this)) {
      return this;
    }
    final parent = this.parent;
    return parent?.findParent(test);
  }
}

extension NodesExtensions<T extends Node> on List<T> {
  List<T> get normalized {
    if (isEmpty) {
      return this;
    }

    if (first.path > last.path) {
      return reversed.toList();
    }

    return this;
  }

  bool allSatisfyInSelection(
    Selection selection,
    bool Function(Delta delta) test,
  ) {
    if (selection.isCollapsed) {
      return false;
    }

    selection = selection.normalized;
    final nodes = this.normalized;

    if (nodes.length == 1) {
      return nodes.first.allSatisfyInSelection(selection, test);
    }

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      var delta = node.delta;
      if (delta == null) {
        continue;
      }

      if (i == 0) {
        delta = delta.slice(selection.start.offset);
      } else if (i == nodes.length - 1) {
        delta = delta.slice(0, selection.end.offset);
      }
      if (!test(delta)) {
        return false;
      }
    }

    return true;
  }
}
