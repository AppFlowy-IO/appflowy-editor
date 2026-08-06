import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const RemoteScrollReproApp());
}

class RemoteScrollReproApp extends StatelessWidget {
  const RemoteScrollReproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
      home: const RemoteScrollReproPage(),
    );
  }
}

class RemoteScrollReproPage extends StatefulWidget {
  const RemoteScrollReproPage({super.key});

  @override
  State<RemoteScrollReproPage> createState() => _RemoteScrollReproPageState();
}

class _RemoteScrollReproPageState extends State<RemoteScrollReproPage> {
  static const _localCursorIndex = 8;
  static const _viewportIndex = 14;
  static const _remoteEditIndex = 30;

  late final EditorState _editorState;
  late final EditorScrollController _editorScrollController;

  bool _isRunning = false;
  int _remoteEditCount = 0;
  String _status = 'Press “Reproduce” to run the two-client sequence.';
  double? _offsetBeforeRemoteEdit;
  double? _offsetAfterRemoteEdit;
  (int, int)? _visibleRangeBeforeRemoteEdit;
  (int, int)? _visibleRangeAfterRemoteEdit;
  Offset? _autoScrollTarget;

  @override
  void initState() {
    super.initState();
    final nodes = List.generate(
      80,
      (index) => paragraphNode(
        text: switch (index) {
          _localCursorIndex =>
            'LOCAL CURSOR — this position belongs to Client A',
          _remoteEditIndex =>
            'REMOTE EDIT TARGET — Client B will edit this paragraph',
          _ => 'Paragraph $index — collaborative document content',
        },
      ),
    );
    _editorState = EditorState(
      document: Document(root: pageNode(children: nodes)),
    );
    _editorScrollController = EditorScrollController(
      editorState: _editorState,
    );
  }

  @override
  void dispose() {
    _editorScrollController.dispose();
    _editorState.dispose();
    super.dispose();
  }

  Future<void> _reproduce() async {
    if (_isRunning) {
      return;
    }
    setState(() {
      _isRunning = true;
      _offsetBeforeRemoteEdit = null;
      _offsetAfterRemoteEdit = null;
      _visibleRangeBeforeRemoteEdit = null;
      _visibleRangeAfterRemoteEdit = null;
      _autoScrollTarget = null;
      _status = 'Client A: placing the local cursor at paragraph 8…';
    });

    await _editorState.updateSelectionWithReason(
      Selection.collapsed(Position(path: const [_localCursorIndex])),
      reason: SelectionUpdateReason.uiEvent,
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));

    _editorScrollController.itemScrollController.jumpTo(
      index: _viewportIndex,
      alignment: 0,
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _editorState.autoScroller?.stopAutoScroll();
    _offsetBeforeRemoteEdit = _editorScrollController.offsetNotifier.value;
    _visibleRangeBeforeRemoteEdit =
        _editorScrollController.visibleRangeNotifier.value;
    if (mounted) {
      setState(() {
        _status = 'Client A: viewport moved away from its cursor. '
            'Client B edits in 2 seconds…';
      });
    }
    await Future<void>.delayed(const Duration(seconds: 2));

    final remotelyEditedNode =
        _editorState.document.nodeAtPath(const [_remoteEditIndex]);
    if (remotelyEditedNode == null) {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _status = 'Unable to find the remote edit target.';
        });
      }
      return;
    }

    _remoteEditCount++;
    final transaction = _editorState.transaction
      ..updateNode(
        remotelyEditedNode,
        {
          ParagraphBlockKeys.delta: (Delta()
                ..insert(
                  'REMOTE EDIT #$_remoteEditCount — received from Client B',
                ))
              .toJson(),
        },
      );
    await _editorState.apply(transaction, isRemote: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _offsetAfterRemoteEdit = _editorScrollController.offsetNotifier.value;
    _visibleRangeAfterRemoteEdit =
        _editorScrollController.visibleRangeNotifier.value;
    _autoScrollTarget = _editorState.autoScroller?.lastOffset;
    if (!mounted) {
      return;
    }
    setState(() {
      _isRunning = false;
      _status = _autoScrollTarget == null
          ? 'No auto-scroll request was observed.'
          : 'BUG REPRODUCED: the remote edit requested local auto-scroll.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote edit viewport-jump reproducer'),
        backgroundColor: const Color(0xFF5E2CA5),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Material(
            color: const Color(0xFFF1EAFE),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('reproduce_remote_scroll'),
                    onPressed: _isRunning ? null : _reproduce,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_isRunning ? 'Running…' : 'Reproduce'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key: const ValueKey('remote_scroll_repro_status'),
                          _status,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Visible blocks before: '
                          '${_formatRange(_visibleRangeBeforeRemoteEdit)}  •  '
                          'after: '
                          '${_formatRange(_visibleRangeAfterRemoteEdit)}  •  '
                          'scroll movement: ${_formatMovement()}  •  '
                          'auto-scroll target: '
                          '${_autoScrollTarget ?? 'none'}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AppFlowyEditor(
              editorState: _editorState,
              editorScrollController: _editorScrollController,
              editorStyle: const EditorStyle.desktop(
                padding: EdgeInsets.symmetric(horizontal: 80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRange((int, int)? range) =>
      range == null ? '—' : '${range.$1}–${range.$2}';

  String _formatMovement() {
    final before = _offsetBeforeRemoteEdit;
    final after = _offsetAfterRemoteEdit;
    if (before == null || after == null) {
      return '—';
    }
    return '${(after - before).toStringAsFixed(1)} px';
  }
}
