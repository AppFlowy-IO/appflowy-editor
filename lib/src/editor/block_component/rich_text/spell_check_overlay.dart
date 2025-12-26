import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/spell_check/spell_checker.dart';
import 'package:flutter/material.dart';

/// Overlay widget that shows spell check suggestions when hovering over misspelled words
class SpellCheckOverlay extends StatefulWidget {
  const SpellCheckOverlay({
    super.key,
    required this.editorState,
    required this.node,
    required this.delegate,
    required this.misspelledCache,
  });

  final EditorState editorState;
  final Node node;
  final SelectableMixin delegate;
  final Map<String, bool> misspelledCache;

  @override
  State<SpellCheckOverlay> createState() => _SpellCheckOverlayState();
}

class _SpellCheckOverlayState extends State<SpellCheckOverlay> {
  OverlayEntry? _overlayEntry;
  String? _hoveredWord;
  Timer? _hoverDebounce;
  bool _hoveringOnPopup = false;

  // Constants
  static const _popupVerticalOffset = 20.0;
  static const _popupMaxWidth = 240.0;
  static const _hoverExitDelay = Duration(milliseconds: 50);
  static const _hoverShowDelay = Duration(milliseconds: 200);
  static const _overlayRemoveDelay = Duration(milliseconds: 100);
  static const _minWordLengthForCheck = 3;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    _hoverDebounce?.cancel();

    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveredWord = null;
  }

  void _scheduleOverlayRemoval([Duration? delay]) {
    _hoverDebounce?.cancel();
    _hoverDebounce = Timer(delay ?? _overlayRemoveDelay, () {
      if (!_hoveringOnPopup) {
        _removeOverlay();
      }
    });
  }

  bool _isValidWordForSpellCheck(String word) {
    return RegExp(r'^\w+$').hasMatch(word) &&
        word.length >= _minWordLengthForCheck;
  }

  ({Offset position, String word, int start, int length})? _getWordAtPosition(
    PointerEvent event,
  ) {
    final localPosition = event.localPosition;
    final globalPosition = widget.delegate.localToGlobal(localPosition);
    final position = widget.delegate.getPositionInOffset(globalPosition);
    final selection = widget.delegate.getWordBoundaryInPosition(position);

    if (selection == null) return null;

    final delta = widget.node.delta;
    if (delta == null) return null;

    final text = delta.toPlainText();
    final start = selection.start.offset;
    final end = selection.end.offset;

    if (start < 0 || end > text.length || start >= end) return null;

    final word = text.substring(start, end);
    return (
      position: globalPosition,
      word: word,
      start: start,
      length: end - start
    );
  }

  Future<void> _showSuggestionsPopup(
    String word,
    Offset position,
    int start,
    int length,
  ) async {
    // Don't show popup if already showing for the same word
    if (_hoveredWord == word && _overlayEntry != null) return;

    _removeOverlay();

    final suggestions =
        await SpellChecker.instance.suggest(word, maxSuggestions: 5);
    if (!mounted || suggestions.isEmpty) return;

    _hoveredWord = word;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + _popupVerticalOffset,
        child: MouseRegion(
          onEnter: (_) {
            _hoveringOnPopup = true;
          },
          onExit: (_) {
            _hoveringOnPopup = false;
            // Small delay to allow for mouse movement between word and popup
            Future.delayed(_hoverExitDelay, () {
              if (!_hoveringOnPopup) {
                _removeOverlay();
              }
            });
          },
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxWidth: _popupMaxWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: suggestions.map((suggestion) {
                  return InkWell(
                    onTap: () =>
                        _replaceMisspelledWord(suggestion, start, length),
                    borderRadius: BorderRadius.circular(8),
                    hoverColor: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_fix_high,
                            size: 16,
                            color: Colors.purple.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _replaceMisspelledWord(
    String suggestion,
    int start,
    int length,
  ) async {
    _removeOverlay();

    final transaction = widget.editorState.transaction;
    transaction.replaceText(widget.node, start, length, suggestion);
    transaction.afterSelection = Selection.collapsed(
      Position(path: widget.node.path, offset: start + suggestion.length),
    );
    await widget.editorState.apply(transaction);

    // Clear the old word from cache since it's been replaced
    if (_hoveredWord != null) {
      widget.misspelledCache.remove(_hoveredWord!.toLowerCase());
    }
  }

  void _handlePointerHover(PointerEvent event) {
    final wordData = _getWordAtPosition(event);
    if (wordData == null) {
      _scheduleOverlayRemoval();
      return;
    }

    final (:position, :word, :start, :length) = wordData;
    if (!_isValidWordForSpellCheck(word)) {
      _scheduleOverlayRemoval();
      return;
    }

    final isMisspelled = widget.misspelledCache[word.toLowerCase()] == true;

    if (isMisspelled) {
      // Hovering on a misspelled word
      if (_hoveredWord != word) {
        // Hovering over a new misspelled word
        _hoverDebounce?.cancel();
        _hoverDebounce = Timer(_hoverShowDelay, () {
          _showSuggestionsPopup(word, position, start, length);
        });
      }
      // If hovering on the same misspelled word, keep showing popup
    } else {
      // Not hovering on a misspelled word
      if (_hoveredWord != null && !_hoveringOnPopup) {
        _scheduleOverlayRemoval();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: MouseRegion(
        onHover: _handlePointerHover,
        onExit: (_) {
          _scheduleOverlayRemoval();
        },
        child: IgnorePointer(
          child: Container(),
        ),
      ),
    );
  }
}
