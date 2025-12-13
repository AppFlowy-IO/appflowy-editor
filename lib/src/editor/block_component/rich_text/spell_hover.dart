import 'package:appflowy_editor/src/service/spell_check/spell_checker.dart';
import 'package:flutter/material.dart';

/// A small hover widget that shows suggestion popup for a misspelled word.
class SpellHover extends StatefulWidget {
  const SpellHover({
    super.key,
    required this.child,
    required this.word,
    required this.onSelected,
  });

  final Widget child;
  final String word;
  final Future<void> Function(String suggestion) onSelected;

  @override
  State<SpellHover> createState() => _SpellHoverState();
}

class _SpellHoverState extends State<SpellHover> {
  OverlayEntry? _entry;
  bool _hoveringOnWord = false;
  bool _hoveringOnPopup = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  bool get _shouldShowOverlay => _hoveringOnWord || _hoveringOnPopup;

  Future<void> _showOverlay() async {
    _removeOverlay();
    final suggestions =
        await SpellChecker.instance.suggest(widget.word, maxSuggestions: 5);

    if (!mounted || suggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 4,
          child: MouseRegion(
            onEnter: (_) {
              _hoveringOnPopup = true;
            },
            onExit: (_) {
              _hoveringOnPopup = false;
              // remove after a short delay to avoid flicker
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!_shouldShowOverlay) _removeOverlay();
              });
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                constraints: const BoxConstraints(maxWidth: 240),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: suggestions
                      .map(
                        (s) => InkWell(
                          onTap: () async {
                            await widget.onSelected(s);
                            _removeOverlay();
                          },
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
                                    s,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _hoveringOnWord = true;
        _showOverlay();
      },
      onExit: (_) {
        _hoveringOnWord = false;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_shouldShowOverlay) _removeOverlay();
        });
      },
      child: widget.child,
    );
  }
}
