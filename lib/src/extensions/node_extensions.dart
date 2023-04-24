import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/core/document/path.dart';
import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/extensions/object_extensions.dart';
import 'package:appflowy_editor/src/render/selection/selectable.dart';
import 'package:flutter/material.dart';

extension NodeExtensions on Node {
  RenderBox? get renderBox =>
      key.currentContext?.findRenderObject()?.unwrapOrNull<RenderBox>();

  BuildContext? get context => key.currentContext;
  SelectableMixin? get selectable =>
      key.currentState?.unwrapOrNull<SelectableMixin>();

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

  bool isSelected(EditorState editorState) {
    final currentSelectedNodes =
        editorState.service.selectionService.currentSelectedNodes;
    return currentSelectedNodes.length == 1 &&
        currentSelectedNodes.first == this;
  }

  /// Returns the first previous node in the subtree that satisfies the given predicate
  Node? previousNodeWhere(bool Function(Node element) test) {
    var previous = this.previous;
    while (previous != null) {
      final last = lastNodeWhere(test);
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
      return previousNodeWhere(test);
    }
    return null;
  }

  /// Returns the last node in the subtree that satisfies the given predicate
  Node? lastNodeWhere(bool Function(Node element) test) {
    final children = this.children.toList().reversed;
    for (final child in children) {
      if (child.children.isNotEmpty) {
        final last = lastNodeWhere(test);
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
}
