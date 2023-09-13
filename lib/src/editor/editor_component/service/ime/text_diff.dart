// https://github.com/singerdmx/flutter-quill/blob/master/lib/src/utils/delta.dart

import 'dart:math' as math;

import 'package:flutter/services.dart';

// Diff between two texts - old text and new text
class Diff {
  Diff(this.start, this.deleted, this.inserted);

  // Start index in old text at which changes begin.
  final int start;

  /// The deleted text
  final String deleted;

  // The inserted text
  final String inserted;

  @override
  String toString() {
    return 'Diff[$start, "$deleted", "$inserted"]';
  }
}

/* Get diff operation between old text and new text */
Diff getDiff(String oldText, String newText, int cursorPosition) {
  var end = oldText.length;
  final delta = newText.length - end;
  for (final limit = math.max(0, cursorPosition - delta);
      end > limit && oldText[end - 1] == newText[end + delta - 1];
      end--) {}
  var start = 0;
  for (final startLimit = cursorPosition - math.max(0, delta);
      start < startLimit && oldText[start] == newText[start];
      start++) {}
  final deleted = (start >= end) ? '' : oldText.substring(start, end);
  final inserted = newText.substring(start, end + delta);
  return Diff(start, deleted, inserted);
}

List<TextEditingDelta> getTextEditingDeltas(
  TextEditingValue? oldValue,
  TextEditingValue newValue,
) {
  if (oldValue == null) {
    return [
      TextEditingDeltaNonTextUpdate(
        oldText: newValue.text,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  }
  final currentText = oldValue.text;
  final diff = getDiff(
    currentText,
    newValue.text,
    newValue.selection.extentOffset,
  );
  if (diff.inserted.isNotEmpty && diff.deleted.isEmpty) {
    return [
      TextEditingDeltaInsertion(
        oldText: currentText,
        textInserted: diff.inserted,
        insertionOffset: diff.start,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  } else if (diff.inserted.isEmpty && diff.deleted.isNotEmpty) {
    return [
      TextEditingDeltaDeletion(
        oldText: currentText,
        selection: newValue.selection,
        composing: newValue.composing,
        deletedRange: TextRange(
          start: diff.start,
          end: diff.start + diff.deleted.length,
        ),
      ),
    ];
  } else if (diff.inserted.isNotEmpty && diff.deleted.isNotEmpty) {
    return [
      TextEditingDeltaReplacement(
        oldText: currentText,
        selection: newValue.selection,
        composing: newValue.composing,
        replacementText: diff.inserted,
        replacedRange: TextRange(
          start: diff.start,
          end: diff.start + diff.deleted.length,
        ),
      ),
    ];
  } else if (diff.inserted.isEmpty && diff.deleted.isEmpty) {
    return [
      TextEditingDeltaNonTextUpdate(
        oldText: newValue.text,
        selection: newValue.selection,
        composing: newValue.composing,
      ),
    ];
  }
  throw UnsupportedError('Unknown diff: $diff');
}
