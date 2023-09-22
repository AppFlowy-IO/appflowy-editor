import 'dart:math';

import 'package:appflowy_editor/src/core/document/attributes.dart';
import 'package:collection/collection.dart';
import 'package:diff_match_patch/diff_match_patch.dart' as diff_match_patch;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../editor/block_component/rich_text/appflowy_rich_text_keys.dart';

// constant number: 2^53 - 1
const int _maxInt = 9007199254740991;

sealed class TextOperation {
  Attributes? get attributes;
  int get length;

  bool get isEmpty => length == 0;

  Map<String, dynamic> toJson();
}

class TextInsert extends TextOperation {
  TextInsert(
    this.text, {
    Attributes? attributes,
  }) : _attributes = attributes;

  String text;
  final Attributes? _attributes;

  @override
  int get length => text.length;

  @override
  Attributes? get attributes => _attributes != null ? {..._attributes!} : null;

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'insert': text,
    };
    if (_attributes != null && _attributes!.isNotEmpty) {
      result['attributes'] = attributes;
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextInsert &&
        other.text == text &&
        _mapEquals(_attributes, other._attributes);
  }

  @override
  int get hashCode => text.hashCode ^ _attributes.hashCode;
}

class TextRetain extends TextOperation {
  TextRetain(
    this.length, {
    Attributes? attributes,
  }) : _attributes = attributes;

  @override
  int length;
  final Attributes? _attributes;

  @override
  Attributes? get attributes => _attributes != null ? {..._attributes!} : null;

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'retain': length,
    };
    if (_attributes != null && _attributes!.isNotEmpty) {
      result['attributes'] = attributes;
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextRetain &&
        other.length == length &&
        _mapEquals(_attributes, other._attributes);
  }

  @override
  int get hashCode => length.hashCode ^ _attributes.hashCode;
}

class TextDelete extends TextOperation {
  TextDelete({
    required this.length,
  });

  @override
  int length;

  @override
  Attributes? get attributes => null;

  @override
  Map<String, dynamic> toJson() {
    return {
      'delete': length,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextDelete && other.length == length;
  }

  @override
  int get hashCode => length.hashCode;
}

/// Deltas are a simple, yet expressive format that can be used to describe contents and changes.
/// The format is JSON based, and is human readable, yet easily parsible by machines.
/// Deltas can describe any rich text document, includes all text and formatting information, without the ambiguity and complexity of HTML.
///

/// Basically borrowed from: https://github.com/quilljs/delta
class Delta extends Iterable<TextOperation> {
  Delta({
    List<TextOperation>? operations,
  }) : _operations = operations ?? <TextOperation>[];

  factory Delta.fromJson(List<dynamic> list) {
    final operations = <TextOperation>[];

    for (final value in list) {
      if (value is Map<String, dynamic>) {
        final op = _textOperationFromJson(value);
        if (op != null) {
          operations.add(op);
        }
      }
    }

    return Delta(operations: operations);
  }

  final List<TextOperation> _operations;
  String? _plainText;

  void addAll(Iterable<TextOperation> textOperations) {
    textOperations.forEach(add);
  }

  void add(TextOperation textOperation) {
    if (textOperation.isEmpty) {
      return;
    }
    _plainText = null;

    if (_operations.isNotEmpty) {
      final lastOp = _operations.last;
      if (lastOp is TextDelete && textOperation is TextDelete) {
        lastOp.length += textOperation.length;
        return;
      }
      if (_mapEquals(lastOp.attributes, textOperation.attributes)) {
        if (lastOp is TextInsert && textOperation is TextInsert) {
          lastOp.text += textOperation.text;
          return;
        }
        // if there is an delete before the insert
        // swap the order
        if (lastOp is TextDelete && textOperation is TextInsert) {
          _operations.removeLast();
          _operations.add(textOperation);
          _operations.add(lastOp);
          return;
        }
        if (lastOp is TextRetain && textOperation is TextRetain) {
          lastOp.length += textOperation.length;
          return;
        }
      }
    }

    _operations.add(textOperation);
  }

  /// The slice() method does not change the original string.
  /// The start and end parameters specifies the part of the string to extract.
  /// The end position is optional.
  Delta slice(int start, [int? end]) {
    final result = Delta();
    final iterator = _OpIterator(_operations);
    int index = 0;

    while ((end == null || index < end) && iterator.hasNext) {
      TextOperation? nextOp;
      if (index < start) {
        nextOp = iterator.next(start - index);
      } else {
        nextOp = iterator.next(end == null ? null : end - index);
        result.add(nextOp);
      }

      index += nextOp.length;
    }

    return result;
  }

  /// Insert operations have an `insert` key defined.
  /// A String value represents inserting text.
  void insert(String text, {Attributes? attributes}) =>
      add(TextInsert(text, attributes: attributes));

  /// Retain operations have a Number `retain` key defined representing the number of characters to keep (other libraries might use the name keep or skip).
  /// An optional `attributes` key can be defined with an Object to describe formatting changes to the character range.
  /// A value of `null` in the `attributes` Object represents removal of that key.
  ///
  /// *Note: It is not necessary to retain the last characters of a document as this is implied.*
  void retain(int length, {Attributes? attributes}) =>
      add(TextRetain(length, attributes: attributes));

  /// Delete operations have a Number `delete` key defined representing the number of characters to delete.
  void delete(int length) => add(TextDelete(length: length));

  /// The length of the string of the [Delta].
  @override
  int get length {
    return _operations.fold(
      0,
      (previousValue, element) => previousValue + element.length,
    );
  }

  /// Returns a Delta that is equivalent to applying the operations of own Delta, followed by another Delta.
  Delta compose(Delta other) {
    final thisIter = _OpIterator(_operations);
    final otherIter = _OpIterator(other._operations);
    final operations = <TextOperation>[];

    final firstOther = otherIter.peek();
    if (firstOther != null &&
        firstOther is TextRetain &&
        firstOther.attributes == null) {
      int firstLeft = firstOther.length;
      while (
          thisIter.peek() is TextInsert && thisIter.peekLength() <= firstLeft) {
        firstLeft -= thisIter.peekLength();
        final next = thisIter.next();
        operations.add(next);
      }
      if (firstOther.length - firstLeft > 0) {
        otherIter.next(firstOther.length - firstLeft);
      }
    }

    final delta = Delta(operations: operations);
    while (thisIter.hasNext || otherIter.hasNext) {
      if (otherIter.peek() is TextInsert) {
        final next = otherIter.next();
        delta.add(next);
      } else if (thisIter.peek() is TextDelete) {
        final next = thisIter.next();
        delta.add(next);
      } else {
        // otherIs
        final length = min(thisIter.peekLength(), otherIter.peekLength());
        final thisOp = thisIter.next(length);
        final otherOp = otherIter.next(length);
        final attributes = composeAttributes(
          thisOp.attributes,
          otherOp.attributes,
          keepNull: thisOp is TextRetain,
        );

        if (otherOp is TextRetain && otherOp.length > 0) {
          TextOperation? newOp;
          if (thisOp is TextRetain) {
            newOp = TextRetain(length, attributes: attributes);
          } else if (thisOp is TextInsert) {
            newOp = TextInsert(thisOp.text, attributes: attributes);
          }

          if (newOp != null) {
            delta.add(newOp);
          }

          // Optimization if rest of other is just retain
          if (!otherIter.hasNext &&
              delta._operations.isNotEmpty &&
              delta._operations.last == newOp) {
            final rest = Delta(operations: thisIter.rest());
            return (delta + rest)..chop();
          }
        } else if (otherOp is TextDelete && (thisOp is TextRetain)) {
          delta.add(otherOp);
        }
      }
    }

    return delta..chop();
  }

  Delta diff(Delta other) {
    if (_operations.equals(other._operations)) {
      return Delta();
    }

    final strings = [this, other].map((e) {
      final text = e.map((op) {
        if (op is TextInsert) {
          return op.text;
        }
        throw Exception('diff() called $e');
      }).join();
      return text;
    }).toList();

    final retDelta = Delta();
    final diffResult = diff_match_patch.diff(strings[0], strings[1]);
    diff_match_patch.DiffMatchPatch().diffCleanupSemantic(diffResult);

    final thisIter = _OpIterator(this);
    final otherIter = _OpIterator(other);

    for (final diff in diffResult) {
      var length = diff.text.length;
      while (length > 0) {
        var opLength = 0;
        switch (diff.operation) {
          case diff_match_patch.DIFF_INSERT:
            opLength = min(otherIter.peekLength(), length);
            retDelta.add(otherIter.next(opLength));
            break;
          case diff_match_patch.DIFF_DELETE:
            opLength = min(length, thisIter.peekLength());
            thisIter.next(opLength);
            retDelta.delete(opLength);
            break;
          case diff_match_patch.DIFF_EQUAL:
            opLength = min(
              min(thisIter.peekLength(), otherIter.peekLength()),
              length,
            );
            final thisOp = thisIter.next(opLength);
            final otherOp = otherIter.next(opLength);
            if (isAttributesEqual(thisOp.attributes, otherOp.attributes)) {
              retDelta.retain(
                opLength,
                attributes: invertAttributes(
                  thisOp.attributes,
                  otherOp.attributes,
                ),
              );
            } else {
              retDelta
                ..add(otherOp)
                ..delete(opLength);
            }
            break;
        }
        length -= opLength;
      }
    }
    return retDelta..trim();
  }

  void trim() {
    if (isNotEmpty) {
      final last = _operations.last;
      if (last is TextRetain &&
          (last.attributes == null || last.attributes!.isEmpty)) {
        _operations.removeLast();
      }
    }
  }

  /// This method joins two Delta together.
  Delta operator +(Delta other) {
    var operations = [..._operations];
    if (other._operations.isNotEmpty) {
      operations.add(other._operations[0]);
      operations.addAll(other._operations.sublist(1));
    }
    return Delta(operations: operations);
  }

  void chop() {
    if (_operations.isEmpty) {
      return;
    }
    _plainText = null;
    final lastOp = _operations.last;
    if (lastOp is TextRetain && (lastOp.attributes?.length ?? 0) == 0) {
      _operations.removeLast();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Delta) {
      return false;
    }
    return listEquals(_operations, other._operations);
  }

  @override
  int get hashCode {
    return Object.hashAll(_operations);
  }

  /// Returned an inverted delta that has the opposite effect of against a base document delta.
  Delta invert(Delta base) {
    final inverted = Delta();
    _operations.fold(0, (int previousValue, op) {
      if (op is TextInsert) {
        inverted.delete(op.length);
      } else if (op is TextRetain && op.attributes == null) {
        inverted.retain(op.length);
        return previousValue + op.length;
      } else if (op is TextDelete || op is TextRetain) {
        final length = op.length;
        final slice = base.slice(previousValue, previousValue + length);
        for (final baseOp in slice._operations) {
          if (op is TextDelete) {
            inverted.add(baseOp);
          } else if (op is TextRetain && op.attributes != null) {
            inverted.retain(
              baseOp.length,
              attributes: invertAttributes(baseOp.attributes, op.attributes),
            );
          }
        }
        return previousValue + length;
      }
      return previousValue;
    });
    return inverted..chop();
  }

  List<dynamic> toJson() {
    return _operations.map((e) => e.toJson()).toList();
  }

  /// This method will return the position of the previous rune.
  ///
  /// Since the encoding of the [String] in Dart is UTF-16.
  /// If you want to find the previous character of a position,
  /// you can't just use the `position - 1` simply.
  ///
  /// This method can help you to compute the position of the previous character.
  int prevRunePosition(int pos) {
    if (pos == 0) {
      return pos - 1;
    }
    final content = toPlainText();
    final boundary = CharacterBoundary(content);
    final index = boundary.getLeadingTextBoundaryAt(pos - 1);
    return index ?? 0;
  }

  /// This method will return the position of the next rune.
  ///
  /// Since the encoding of the [String] in Dart is UTF-16.
  /// If you want to find the next character of a position,
  /// you can't just use the `position + 1` simply.
  ///
  /// This method can help you to compute the position of the next character.
  int nextRunePosition(int pos) {
    final content = toPlainText();
    if (pos >= content.length - 1) {
      return content.length;
    }
    final boundary = CharacterBoundary(content);
    final index = boundary.getTrailingTextBoundaryAt(pos);
    return index ?? content.length;
  }

  String toPlainText() {
    _plainText ??=
        _operations.whereType<TextInsert>().map((op) => op.text).join();
    return _plainText!;
  }

  @override
  Iterator<TextOperation> get iterator => _operations.iterator;

  static TextOperation? _textOperationFromJson(Map<String, dynamic> json) {
    TextOperation? operation;

    if (json['insert'] is String) {
      final attributes = json['attributes'] as Map<String, dynamic>?;
      operation = TextInsert(
        json['insert'] as String,
        attributes: attributes != null ? {...attributes} : null,
      );
    } else if (json['retain'] is int) {
      final attrs = json['attributes'] as Map<String, dynamic>?;
      operation = TextRetain(
        json['retain'] as int,
        attributes: attrs != null ? {...attrs} : null,
      );
    } else if (json['delete'] is int) {
      operation = TextDelete(length: json['delete'] as int);
    }

    return operation;
  }

  Attributes? sliceAttributes(int index) {
    if (index <= 0) {
      return null;
    }

    final attributes = slice(index - 1, index).first.attributes;
    if (attributes == null ||
        !attributes.keys.every(
          (element) => AppFlowyRichTextKeys.supportSliced.contains(element),
        )) {
      return null;
    }

    return attributes;
  }
}

class _OpIterator {
  _OpIterator(
    Iterable<TextOperation> operations,
  ) : _operations = UnmodifiableListView(operations);

  final UnmodifiableListView<TextOperation> _operations;
  int _index = 0;
  int _offset = 0;

  bool get hasNext {
    return peekLength() < _maxInt;
  }

  TextOperation? peek() {
    if (_index >= _operations.length) {
      return null;
    }

    return _operations[_index];
  }

  int peekLength() {
    if (_index < _operations.length) {
      final op = _operations[_index];
      return op.length - _offset;
    }
    return _maxInt;
  }

  TextOperation next([int? length]) {
    length ??= _maxInt;

    if (_index >= _operations.length) {
      return TextRetain(_maxInt);
    }

    final nextOp = _operations[_index];

    final offset = _offset;
    final opLength = nextOp.length;
    if (length >= opLength - offset) {
      length = opLength - offset;
      _index += 1;
      _offset = 0;
    } else {
      _offset += length;
    }

    switch (nextOp) {
      case TextDelete _:
        return TextDelete(length: length);
      case TextRetain _:
        return TextRetain(length, attributes: nextOp.attributes);
      case TextInsert _:
        return TextInsert(
          nextOp.text.substring(offset, offset + length),
          attributes: nextOp.attributes,
        );
    }
  }

  List<TextOperation> rest() {
    if (!hasNext) {
      return [];
    } else if (_offset == 0) {
      return _operations.sublist(_index);
    } else {
      final offset = _offset;
      final index = _index;
      final next = this.next();
      final rest = _operations.sublist(_index);
      _offset = offset;
      _index = index;
      return [next] + rest;
    }
  }
}

bool _mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if ((a == null || a.isEmpty) && (b == null || b.isEmpty)) {
    return true;
  }
  return mapEquals(a, b);
}
