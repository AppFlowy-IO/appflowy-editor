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
  int? _hoveredWordStart;
  int? _hoveredWordLength;
  Timer? _hoverDebounce;

  @override
  void dispose() {
    _removeOverlay();
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
    _removeOverlay();
    
    final suggestions = await SpellChecker.instance.suggest(word, maxSuggestions: 5);
    if (!mounted || suggestions.isEmpty) return;

    _hoveredWord = word;
    _hoveredWordStart = start;
    _hoveredWordLength = length;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + 20,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: suggestions.map((suggestion) {
                return InkWell(
                  onTap: () => _replaceMisspelledWord(suggestion, start, length),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _replaceMisspelledWord(String suggestion, int start, int length) async {
    _removeOverlay();
    
    final transaction = widget.editorState.transaction;
    transaction.replaceText(widget.node, start, length, suggestion);
    transaction.afterSelection = Selection.collapsed(
      Position(path: widget.node.path, offset: start + suggestion.length),
    );
    await widget.editorState.apply(transaction);
  }

  void _handlePointerHover(PointerEvent event) {
    final localPosition = event.localPosition;
    final selection = widget.delegate.getWordBoundaryInPosition(
      widget.delegate.getPositionInOffset(
        widget.delegate.localToGlobal(localPosition),
      ),
    );

    if (selection == null) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), _removeOverlay);
      return;
    }

    final delta = widget.node.delta;
    if (delta == null) return;

    final text = delta.toPlainText();
    final start = selection.start.offset;
    final end = selection.end.offset;
    
    if (start < 0 || end > text.length) return;
    
    final word = text.substring(start, end);
    final isWord = RegExp(r'^\w+$').hasMatch(word);
    
    if (!isWord || word.length < 3) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), _removeOverlay);
      return;
    }

    final isMisspelled = widget.misspelledCache[word.toLowerCase()] == true;
    
    if (isMisspelled && _hoveredWord != word) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 300), () {
        final globalPosition = widget.delegate.localToGlobal(localPosition);
        _showSuggestionsPopup(word, globalPosition, start, end - start);
      });
    } else if (!isMisspelled && _hoveredWord != null) {
      _hoverDebounce?.cancel();
      _hoverDebounce = Timer(const Duration(milliseconds: 100), _removeOverlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: MouseRegion(
        onHover: _handlePointerHover,
        onExit: (_) {
          _hoverDebounce?.cancel();
          _hoverDebounce = Timer(const Duration(milliseconds: 300), _removeOverlay);
        },
        child: IgnorePointer(
          child: Container(),
        ),
      ),
    );
  }
}
