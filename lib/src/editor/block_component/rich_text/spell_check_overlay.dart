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
        top: position.dy + 20,
        child: MouseRegion(
          onEnter: (_) {
            _hoveringOnPopup = true;
          },
          onExit: (_) {
            _hoveringOnPopup = false;
            // Small delay to allow for mouse movement between word and popup
            Future.delayed(const Duration(milliseconds: 50), () {
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
              constraints: const BoxConstraints(maxWidth: 240),
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
    final localPosition = event.localPosition;

    // Get the word at the current mouse position
    final globalPosition = widget.delegate.localToGlobal(localPosition);
    final position = widget.delegate.getPositionInOffset(globalPosition);
    final selection = widget.delegate.getWordBoundaryInPosition(position);

    if (selection == null) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
        if (!_hoveringOnPopup) {
          _removeOverlay();
        }
      });

      return;
    }

    final delta = widget.node.delta;
    if (delta == null) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
        if (!_hoveringOnPopup) {
          _removeOverlay();
        }
      });

      return;
    }

    final text = delta.toPlainText();
    final start = selection.start.offset;
    final end = selection.end.offset;

    if (start < 0 || end > text.length || start >= end) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
        if (!_hoveringOnPopup) {
          _removeOverlay();
        }
      });

      return;
    }

    final word = text.substring(start, end);
    final isWord = RegExp(r'^\w+$').hasMatch(word);

    // Only show suggestions for actual words with 3+ characters
    if (!isWord || word.length < 3) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
        if (!_hoveringOnPopup) {
          _removeOverlay();
        }
      });

      return;
    }

    final isMisspelled = widget.misspelledCache[word.toLowerCase()] == true;

    if (isMisspelled) {
      // Hovering on a misspelled word
      if (_hoveredWord != word) {
        // Hovering over a new misspelled word
        _hoverDebounce?.cancel();
        _hoverDebounce = Timer(const Duration(milliseconds: 200), () {
          _showSuggestionsPopup(word, globalPosition, start, end - start);
        });
      }
      // If hovering on the same misspelled word, keep showing popup
    } else {
      // Not hovering on a misspelled word
      if (_hoveredWord != null && !_hoveringOnPopup) {
        _hoverDebounce?.cancel();
        _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
          if (!_hoveringOnPopup) {
            _removeOverlay();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: MouseRegion(
        onHover: _handlePointerHover,
        onExit: (_) {
          _hoverDebounce?.cancel();
          _hoverDebounce = Timer(const Duration(milliseconds: 100), () {
            if (!_hoveringOnPopup) {
              _removeOverlay();
            }
          });
        },
        child: IgnorePointer(
          child: Container(),
        ),
      ),
    );
  }
}
