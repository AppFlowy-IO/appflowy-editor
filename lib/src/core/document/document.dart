import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';

/// [Document] represents an AppFlowy Editor document structure.
///
/// It stores the root of the document.
///
/// **DO NOT** directly mutate the properties of a [Document] object.
///
class Document {
  Document({
    required this.root,
  });

  /// Constructs a [Document] from a JSON strcuture.
  ///
  /// _Example of a [Document] in JSON format:_
  /// ```
  /// {
  ///   'document': {
  ///     'type': 'page',
  ///     'children': [
  ///       {
  ///         'type': 'paragraph',
  ///         'data': {
  ///           'delta': [
  ///             { 'insert': 'Welcome ' },
  ///             { 'insert': 'to ' },
  ///             { 'insert': 'AppFlowy!' }
  ///           ]
  ///         }
  ///       }
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  factory Document.fromJson(Map<String, dynamic> json) {
    assert(json['document'] is Map);

    final document = Map<String, Object>.from(json['document'] as Map);
    final root = Node.fromJson(document);
    return Document(root: root);
  }

  /// Creates a empty document with a single text node.
  @Deprecated('use Document.blank() instead')
  factory Document.empty() {
    final root = Node(
      type: 'document',
      children: LinkedList<Node>()..add(TextNode.empty()),
    );
    return Document(
      root: root,
    );
  }

  /// Creates a blank [Document] containing an empty root [Node].
  ///
  /// If [withInitialText] is true, the document will contain an empty
  /// paragraph [Node].
  ///
  factory Document.blank({bool withInitialText = false}) {
    final root = Node(
      type: 'page',
      children: withInitialText ? [paragraphNode()] : [],
    );
    return Document(
      root: root,
    );
  }

  /// The root [Node] of the [Document]
  final Node root;

  /// First node of the document.
  Node? get first => root.children.first;

  /// Last node of the document.
  Node? get last {
    var last = root.children.last;
    while (last.children.isNotEmpty) {
      last = last.children.last;
    }
    return last;
  }

  /// Returns the node at the given [path].
  Node? nodeAtPath(Path path) {
    return root.childAtPath(path);
  }

  /// Inserts a [Node]s at the given [Path].
  bool insert(Path path, Iterable<Node> nodes) {
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

  /// Deletes the [Node]s at the given [Path].
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

  /// Updates the [Node] at the given [Path]
  bool update(Path path, Attributes attributes) {
    // if the path is empty, it means the root node.
    if (path.isEmpty) {
      root.updateAttributes(attributes);
      return true;
    }
    final target = nodeAtPath(path);
    if (target == null) {
      return false;
    }
    target.updateAttributes(attributes);
    return true;
  }

  /// Updates the [Node] with [Delta] at the given [Path]
  bool updateText(Path path, Delta delta) {
    if (path.isEmpty) {
      return false;
    }
    final target = nodeAtPath(path);
    final targetDelta = target?.delta;
    if (target == null || targetDelta == null) {
      return false;
    }
    target.updateAttributes({'delta': (targetDelta.compose(delta)).toJson()});
    return true;
  }

  /// Returns whether the root [Node] does not contain
  /// any text.
  ///
  bool get isEmpty {
    if (root.children.isEmpty) {
      return true;
    }

    if (root.children.length > 1) {
      return false;
    }

    final node = root.children.first;
    final delta = node.delta;
    if (delta != null && (delta.isEmpty || delta.toPlainText().isEmpty)) {
      return true;
    }

    return false;
  }

  /// Encodes the [Document] into a JSON structure.
  ///
  Map<String, Object> toJson() {
    return {
      'document': root.toJson(),
    };
  }
}
