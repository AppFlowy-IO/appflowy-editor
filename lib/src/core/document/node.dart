import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

/// [Node] represents a node in the document tree.
///
/// It contains three parts:
///   - [type]: The type of the node to determine which block component to render it.
///   - [data]: The data of the node to determine how to render it.
///   - [children]: The children of the node.
///
///
/// Json format:
/// {
///   'type': string,
///   'data': Map<String, Object>
///   'children': List<Node>,
/// }
final class Node extends ChangeNotifier with LinkedListEntry<Node> {
  Node({
    required this.type,
    String? id,
    this.parent,
    Attributes attributes = const {},
    Iterable<Node> children = const [],
  })  : _children = LinkedList<Node>()
          ..addAll(
            children.map(
              (e) => e..unlink(),
            ),
          ), // unlink the given children to avoid the error of "node has already a parent"
        _attributes = attributes,
        id = id ?? nanoid(10) {
    for (final child in this.children) {
      child.parent = this;
    }
  }

  factory Node.fromJson(Map<String, Object> json) {
    final node = Node(
      type: json['type'] as String,
      attributes: Attributes.from(json['data'] as Map? ?? {}),
      children: (json['children'] as List? ?? [])
          .map((e) => Map<String, Object>.from(e))
          .map((e) => Node.fromJson(e)),
    );

    for (final child in node.children) {
      child.parent = node;
    }

    return node;
  }

  /// The type of the node.
  final String type;

  /// The id of the node.
  final String id;

  @Deprecated('Use type instead')
  String get subtype => type;

  // @Deprecated('Use type instead')
  // String get id => type;

  /// The parent of the node.
  Node? parent;

  /// The children of the node.
  final LinkedList<Node> _children;
  Iterable<Node> get children => _children.toList(growable: false);

  /// The attributes of the node.
  Attributes _attributes;
  Attributes get attributes => {..._attributes};

  /// The path of the node.
  Path get path => _computePath();

  // Render Part
  final key = GlobalKey();
  final layerLink = LayerLink();

  /// Update the attributes of the node.
  ///
  ///
  void updateAttributes(Attributes attributes) {
    _attributes = composeAttributes(this.attributes, attributes) ?? {};

    notifyListeners();
  }

  Node? childAtIndexOrNull(int index) {
    if (children.length <= index || index < 0) {
      return null;
    }

    return children.elementAt(index);
  }

  Node? childAtPath(Path path) {
    if (path.isEmpty) {
      return this;
    }

    final index = path.first;
    final child = childAtIndexOrNull(index);
    return child?.childAtPath(path.sublist(1));
  }

  void insert(Node entry, {int? index}) {
    final length = _children.length;
    index ??= length;

    Log.editor.debug('insert Node $entry at path ${path + [index]}}');

    entry.parent = this;

    if (children.isEmpty) {
      _children.add(entry);
      notifyListeners();
      return;
    }

    // If index is out of range, insert at the end.
    // If index is negative, insert at the beginning.
    // If index is positive, insert at the index.
    if (index >= length) {
      _children.last.insertAfter(entry);
    } else if (index <= 0) {
      _children.first.insertBefore(entry);
    } else {
      childAtIndexOrNull(index)?.insertBefore(entry);
    }
  }

  @override
  void insertAfter(Node entry) {
    entry.parent = parent;
    super.insertAfter(entry);

    // Notifies the new node.
    parent?.notifyListeners();
  }

  @override
  void insertBefore(Node entry) {
    entry.parent = parent;
    super.insertBefore(entry);

    // Notifies the new node.
    parent?.notifyListeners();
  }

  @override
  void unlink() {
    if (parent == null) {
      return;
    }
    Log.editor.debug('delete Node $this from path $path');
    super.unlink();

    parent?.notifyListeners();
    parent = null;
  }

  @override
  String toString() {
    return '''Node(id: $id,
    type: $type,
    attributes: $attributes,
    children: $children,
    )''';
  }

  Delta? get delta {
    if (attributes['delta'] is List) {
      return Delta.fromJson(attributes['delta']);
    }
    return null;
  }

  Map<String, Object> toJson() {
    final map = <String, Object>{
      'type': type,
    };
    if (children.isNotEmpty) {
      map['children'] = children
          .map(
            (node) => node.toJson(),
          )
          .toList(growable: false);
    }
    if (attributes.isNotEmpty) {
      map['data'] = attributes;
    }
    return map;
  }

  Node copyWith({
    String? type,
    Iterable<Node>? children,
    Attributes? attributes,
  }) {
    final node = Node(
      type: type ?? this.type,
      id: nanoid(10),
      attributes: attributes ?? {...this.attributes},
      children: children ?? [],
    );
    if (children == null && this.children.isNotEmpty) {
      for (final child in this.children) {
        node._children.add(
          child.copyWith()..parent = node,
        );
      }
    }
    return node;
  }

  Path _computePath([Path previous = const []]) {
    if (parent == null) {
      return previous;
    }
    final index = parent!.children.toList().indexOf(this);
    return parent!._computePath([index, ...previous]);
  }
}

@Deprecated('Use Paragraph instead')
final class TextNode extends Node {
  TextNode({
    required Delta delta,
    Iterable<Node>? children,
    Attributes? attributes,
  })  : _delta = delta,
        super(
          type: 'text',
          children: children?.toList() ?? [],
          attributes: attributes ?? {},
          id: '',
        );

  TextNode.empty({Attributes? attributes})
      : _delta = Delta(operations: [TextInsert('')]),
        super(
          type: 'text',
          attributes: attributes ?? {},
        );

  @override
  @Deprecated('Use type instead')
  String get subtype => '';

  Delta _delta;
  @override
  Delta get delta => _delta;
  set delta(Delta v) {
    _delta = v;
    notifyListeners();
  }

  @override
  Map<String, Object> toJson() {
    final map = super.toJson();
    map['delta'] = delta.toJson();
    return map;
  }

  @override
  TextNode copyWith({
    String? type = 'text',
    Iterable<Node>? children,
    Attributes? attributes,
    Delta? delta,
    String? id,
  }) {
    final textNode = TextNode(
      children: children ?? [],
      attributes: attributes ?? this.attributes,
      delta: delta ?? this.delta,
    );
    if (children == null && this.children.isNotEmpty) {
      for (final child in this.children) {
        textNode._children.add(
          child.copyWith()..parent = textNode,
        );
      }
    }
    return textNode;
  }

  String toPlainText() => _delta.toPlainText();
}

extension NodeEquality on Iterable<Node> {
  bool equals(Iterable<Node> other) {
    if (length != other.length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (!_nodeEquals(elementAt(i), other.elementAt(i))) {
        return false;
      }
    }
    return true;
  }

  bool _nodeEquals<T, U>(T base, U other) =>
      identical(this, other) ||
      base is Node &&
          other is Node &&
          other.type == base.type &&
          other.children.equals(base.children);
}
