import 'dart:collection';

import 'package:appflowy_editor/src/core/document/attributes.dart';
import 'package:appflowy_editor/src/core/document/deprecated/node.dart';
import 'package:appflowy_editor/src/core/document/path.dart';
import 'package:appflowy_editor/src/core/document/text_delta.dart';

///
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
///
/// ONLY USE FOR MIGRATION.
///
class DocumentV0 {
  DocumentV0({
    required this.root,
  });

  factory DocumentV0.fromJson(Map<String, dynamic> json) {
    assert(json['document'] is Map);

    final document = Map<String, Object>.from(json['document'] as Map);
    final root = NodeV0.fromJson(document);
    return DocumentV0(root: root);
  }

  /// Creates a empty document with a single text node.
  factory DocumentV0.empty() {
    final root = NodeV0(
      type: 'editor',
      children: LinkedList<NodeV0>()..add(TextNodeV0.empty()),
    );
    return DocumentV0(
      root: root,
    );
  }

  final NodeV0 root;

  /// Returns the node at the given [path].
  NodeV0? nodeAtPath(Path path) {
    return root.childAtPath(path);
  }

  /// Inserts a [NodeV0]s at the given [Path].
  bool insert(Path path, Iterable<NodeV0> nodes) {
    if (path.isEmpty || nodes.isEmpty) {
      return false;
    }

    final target = nodeAtPath(path);
    if (target != null) {
      for (final node in nodes) {
        target.insertBefore(node);
      }
      return true;
    }

    final parent = nodeAtPath(path.parent);
    if (parent != null) {
      for (var i = 0; i < nodes.length; i++) {
        parent.insert(nodes.elementAt(i), index: path.last + i);
      }
      return true;
    }

    return false;
  }

  /// Deletes the [NodeV0]s at the given [Path].
  bool delete(Path path, [int length = 1]) {
    if (path.isEmpty || length <= 0) {
      return false;
    }
    var target = nodeAtPath(path);
    if (target == null) {
      return false;
    }
    while (target != null && length > 0) {
      final next = target.next;
      target.unlink();
      target = next;
      length--;
    }
    return true;
  }

  /// Updates the [NodeV0] at the given [Path]
  bool update(Path path, Attributes attributes) {
    if (path.isEmpty) {
      return false;
    }
    final target = nodeAtPath(path);
    if (target == null) {
      return false;
    }
    target.updateAttributes(attributes);
    return true;
  }

  /// Updates the [TextNodeV0] at the given [Path]
  bool updateText(Path path, Delta delta) {
    if (path.isEmpty) {
      return false;
    }
    final target = nodeAtPath(path);
    if (target == null || target is! TextNodeV0) {
      return false;
    }
    target.delta = target.delta.compose(delta);
    return true;
  }

  bool get isEmpty {
    if (root.children.isEmpty) {
      return true;
    }

    if (root.children.length > 1) {
      return false;
    }

    final node = root.children.first;
    if (node is TextNodeV0 &&
        (node.delta.isEmpty || node.delta.toPlainText().isEmpty)) {
      return true;
    }

    return false;
  }

  Map<String, Object> toJson() {
    return {
      'document': root.toJson(),
    };
  }
}
