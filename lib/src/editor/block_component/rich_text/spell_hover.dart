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
  bool _hovering = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  Future<void> _showOverlay() async {
    _removeOverlay();
    final suggestions = await SpellChecker.instance.suggest(widget.word, maxSuggestions: 5);

    if (!mounted || suggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _entry = OverlayEntry(builder: (context) {
      return Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        child: MouseRegion(
          onExit: (_) {
            // remove after a short delay to avoid flicker
            Future.delayed(const Duration(milliseconds: 150), () {
              if (!_hovering) _removeOverlay();
            });
          },
          child: Material(
            elevation: 4,
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: suggestions
                    .map(
                      (s) => InkWell(
                        onTap: () async {
                          await widget.onSelected(s);
                          _removeOverlay();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          child: Text(s),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _hovering = true;
        _showOverlay();
      },
      onExit: (_) {
        _hovering = false;
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!_hovering) _removeOverlay();
        });
      },
      child: widget.child,
    );
  }
}
