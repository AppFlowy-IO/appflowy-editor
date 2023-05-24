import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:appflowy_editor/src/core/document/attributes.dart';
import 'package:appflowy_editor/src/core/document/path.dart';
import 'package:appflowy_editor/src/core/document/text_delta.dart';
import 'package:appflowy_editor/src/core/legacy/built_in_attribute_keys.dart';

///
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
/// ⚠️ THIS FILE HAS BEEN DEPRECATED.
///
/// ONLY USE FOR MIGRATION.
///
class NodeV0 extends ChangeNotifier with LinkedListEntry<NodeV0> {
  NodeV0({
    required this.type,
    Attributes? attributes,
    this.parent,
    LinkedList<NodeV0>? children,
  })  : children = children ?? LinkedList<NodeV0>(),
        _attributes = attributes ?? {} {
    for (final child in this.children) {
      child.parent = this;
    }
  }

  factory NodeV0.fromJson(Map<String, Object> json) {
    assert(json['type'] is String);

    final jType = json['type'] as String;
    final jChildren = json['children'] as List?;
    final jAttributes = json['attributes'] != null
        ? Attributes.from(json['attributes'] as Map)
        : Attributes.from({});

    final children = LinkedList<NodeV0>();
    if (jChildren != null) {
      children.addAll(
        jChildren.map(
          (jChild) => NodeV0.fromJson(
            Map<String, Object>.from(jChild),
          ),
        ),
      );
    }

    NodeV0 node;

    if (jType == 'text') {
      final jDelta = json['delta'] as List<dynamic>?;
      final delta = jDelta == null ? Delta() : Delta.fromJson(jDelta);
      node = TextNodeV0(
        children: children,
        attributes: jAttributes,
        delta: delta,
      );
    } else {
      node = NodeV0(
        type: jType,
        children: children,
        attributes: jAttributes,
      );
    }

    for (final child in children) {
      child.parent = node;
    }

    return node;
  }

  final String type;
  final LinkedList<NodeV0> children;
  NodeV0? parent;
  Attributes _attributes;

  // Renderable
  final key = GlobalKey();
  final layerLink = LayerLink();

  Attributes get attributes => {..._attributes};

  String get id {
    if (subtype != null) {
      return '$type/$subtype';
    }
    return type;
  }

  String? get subtype {
    if (attributes[BuiltInAttributeKey.subtype] is String) {
      return attributes[BuiltInAttributeKey.subtype] as String;
    }
    return null;
  }

  Path get path => _computePath();

  void updateAttributes(Attributes attributes) {
    final oldAttributes = this.attributes;

    _attributes = composeAttributes(this.attributes, attributes) ?? {};

    // Notifies the new attributes
    // if attributes contains 'subtype', should notify parent to rebuild node
    // else, just notify current node.
    bool shouldNotifyParent =
        this.attributes['subtype'] != oldAttributes['subtype'];
    shouldNotifyParent ? parent?.notifyListeners() : notifyListeners();
  }

  NodeV0? childAtIndex(int index) {
    if (children.length <= index || index < 0) {
      return null;
    }

    return children.elementAt(index);
  }

  NodeV0? childAtPath(Path path) {
    if (path.isEmpty) {
      return this;
    }

    return childAtIndex(path.first)?.childAtPath(path.sublist(1));
  }

  void insert(NodeV0 entry, {int? index}) {
    final length = children.length;
    index ??= length;

    if (children.isEmpty) {
      entry.parent = this;
      children.add(entry);
      notifyListeners();
      return;
    }

    // If index is out of range, insert at the end.
    // If index is negative, insert at the beginning.
    // If index is positive, insert at the index.
    if (index >= length) {
      children.last.insertAfter(entry);
    } else if (index <= 0) {
      children.first.insertBefore(entry);
    } else {
      childAtIndex(index)?.insertBefore(entry);
    }
  }

  @override
  void insertAfter(NodeV0 entry) {
    entry.parent = parent;
    super.insertAfter(entry);

    // Notifies the new node.
    parent?.notifyListeners();
  }

  @override
  void insertBefore(NodeV0 entry) {
    entry.parent = parent;
    super.insertBefore(entry);

    // Notifies the new node.
    parent?.notifyListeners();
  }

  @override
  void unlink() {
    super.unlink();

    parent?.notifyListeners();
    parent = null;
  }

  Map<String, Object> toJson() {
    var map = <String, Object>{
      'type': type,
    };
    if (children.isNotEmpty) {
      map['children'] =
          children.map((node) => node.toJson()).toList(growable: false);
    }
    if (attributes.isNotEmpty) {
      map['attributes'] = attributes;
    }
    return map;
  }

  NodeV0 copyWith({
    String? type,
    LinkedList<NodeV0>? children,
    Attributes? attributes,
  }) {
    final node = NodeV0(
      type: type ?? this.type,
      attributes: attributes ?? {...this.attributes},
      children: children,
    );
    if (children == null && this.children.isNotEmpty) {
      for (final child in this.children) {
        node.children.add(
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
    var index = 0;
    for (final child in parent!.children) {
      if (child == this) {
        break;
      }
      index += 1;
    }
    return parent!._computePath([index, ...previous]);
  }
}

class TextNodeV0 extends NodeV0 {
  TextNodeV0({
    required Delta delta,
    LinkedList<NodeV0>? children,
    Attributes? attributes,
  })  : _delta = delta,
        super(
          type: 'text',
          children: children,
          attributes: attributes ?? {},
        );

  TextNodeV0.empty({Attributes? attributes})
      : _delta = Delta(operations: [TextInsert('')]),
        super(
          type: 'text',
          attributes: attributes ?? {},
        );

  Delta _delta;
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
  TextNodeV0 copyWith({
    String? type = 'text',
    LinkedList<NodeV0>? children,
    Attributes? attributes,
    Delta? delta,
  }) {
    final textNode = TextNodeV0(
      children: children,
      attributes: attributes ?? this.attributes,
      delta: delta ?? this.delta,
    );
    if (children == null && this.children.isNotEmpty) {
      for (final child in this.children) {
        textNode.children.add(
          child.copyWith()..parent = textNode,
        );
      }
    }
    return textNode;
  }

  String toPlainText() => _delta.toPlainText();
}

extension NodeV0Equality on Iterable<NodeV0> {
  bool equals(Iterable<NodeV0> other) {
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

  bool _nodeEquals<T, U>(T base, U other) {
    if (identical(this, other)) return true;

    return base is NodeV0 &&
        other is NodeV0 &&
        other.type == base.type &&
        other.children.equals(base.children);
  }
}
