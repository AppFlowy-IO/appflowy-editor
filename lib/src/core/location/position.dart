import 'package:appflowy_editor/src/core/document/path.dart';

/// Represents a position within the document.
///
/// A position is defined by two components:
/// - [path]: The hierarchical path to a node in the document tree
/// - [offset]: The character offset within that node
///
/// Example:
/// ```dart
/// // Position at character 5 in the first node
/// final pos = Position(path: [0], offset: 5);
///
/// // Position at character 10 in the second child of the third node
/// final pos2 = Position(path: [2, 1], offset: 10);
/// ```
///
/// Positions are used to define cursor locations and selection boundaries.
class Position {
  /// The hierarchical path to the node in the document tree.
  ///
  /// For example, [0] points to the first node, [2, 1] points to
  /// the second child of the third node.
  final Path path;

  /// The character offset within the node.
  ///
  /// This is the zero-based index of the character position within
  /// the node's text content.
  final int offset;

  /// Creates a position with the specified [path] and [offset].
  ///
  /// The offset defaults to 0 if not provided.
  Position({
    required this.path,
    this.offset = 0,
  });

  /// Creates an invalid position.
  ///
  /// Used to represent an undefined or error state.
  /// Has a path of [-1] and offset of -1.
  Position.invalid()
      : path = [-1],
        offset = -1;

  /// Creates a position from a JSON map.
  ///
  /// The JSON should have 'path' (array) and optionally 'offset' (int).
  factory Position.fromJson(Map<String, dynamic> json) {
    final path = Path.from(json['path'] as List);
    final offset = json['offset'];

    return Position(
      path: path,
      offset: offset ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Position &&
        other.path.equals(path) &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(offset, Object.hashAll(path));

  @override
  String toString() => 'path = $path, offset = $offset';

  /// Creates a copy of this position with the given fields replaced.
  ///
  /// If [path] or [offset] are not provided, the current values are used.
  Position copyWith({Path? path, int? offset}) {
    return Position(
      path: path ?? this.path,
      offset: offset ?? this.offset,
    );
  }

  /// Converts this position to a JSON map.
  ///
  /// Returns a map with 'path' and 'offset' keys.
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'offset': offset,
    };
  }
}
