import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../test_helper.dart';

/// Records the auto scroll calls that the selection service makes.
class _RecordingScrollService extends StatefulWidget {
  const _RecordingScrollService({super.key, required this.child});

  final Widget child;

  @override
  State<_RecordingScrollService> createState() =>
      _RecordingScrollServiceState();
}

class _RecordingScrollServiceState extends State<_RecordingScrollService>
    implements AppFlowyScrollService {
  final List<Offset> autoScrollOffsets = [];
  final List<double> autoScrollEdgeOffsets = [];
  final List<AxisDirection?> autoScrollDirections = [];
  int stopAutoScrollCount = 0;

  /// When it is set, the auto scroll calls are forwarded to the real auto
  /// scroller, so that the tests are able to observe the real scrolling.
  AutoScroller? autoScroller;

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
  }) {
    autoScrollOffsets.add(offset);
    autoScrollEdgeOffsets.add(edgeOffset);
    autoScrollDirections.add(direction);

    autoScroller?.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration,
    );
  }

  @override
  void stopAutoScroll() {
    stopAutoScrollCount += 1;
  }

  @override
  double get dy => 0;

  @override
  double get maxScrollExtent => 0;

  @override
  double get minScrollExtent => 0;

  @override
  double? get onePageHeight => 600;

  @override
  int? get page => 0;

  @override
  ScrollController get scrollController => ScrollController();

  @override
  void scrollTo(
    double dy, {
    Duration? duration,
  }) {}

  @override
  void jumpTo(int index) {}

  @override
  void jumpToTop() {}

  @override
  void jumpToBottom() {}

  @override
  void goBallistic(double velocity) {}

  @override
  void enable() {}

  @override
  void disable() {}

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() {
  group('Mobile auto scroll while dragging a selection handle', () {
    late EditorState editorState;
    late _RecordingScrollServiceState scrollService;

    Future<void> buildEditor(WidgetTester tester) async {
      final document = Document.blank()
        ..insert([0], [paragraphNode(text: 'Hello World!')]);
      editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(Position(path: [0, 0]));

      final scrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: true,
      );

      await tester.buildAndPump(
        Provider<EditorState>.value(
          value: editorState,
          child: Provider<EditorScrollController>.value(
            value: scrollController,
            child: _RecordingScrollService(
              key: editorState.service.scrollServiceKey,
              child: MobileSelectionServiceWidget(
                key: editorState.service.selectionServiceKey,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      scrollService = tester.state<_RecordingScrollServiceState>(
        find.byType(_RecordingScrollService),
      );
    }

    testWidgets(
      'the auto scroll is anchored on the pointer, not on the selection',
      (tester) async {
        await buildEditor(tester);

        final selectionService = editorState.service.selectionService;
        const pointer = Offset(120, 640);

        selectionService.onPanStart(
          DragStartDetails(globalPosition: const Offset(120, 100)),
          MobileSelectionDragMode.rightSelectionHandle,
        );
        selectionService.onPanUpdate(
          DragUpdateDetails(
            globalPosition: pointer,
            delta: const Offset(0, 540),
          ),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        expect(scrollService.autoScrollOffsets, isNotEmpty);
        expect(
          scrollService.autoScrollOffsets.last,
          pointer,
          reason: 'the pointer should be the anchor of the auto scroll',
        );
      },
    );

    testWidgets(
      'the auto scroll uses a small edge offset while dragging',
      (tester) async {
        await buildEditor(tester);

        final selectionService = editorState.service.selectionService;

        selectionService.onPanStart(
          DragStartDetails(globalPosition: const Offset(120, 100)),
          MobileSelectionDragMode.rightSelectionHandle,
        );
        selectionService.onPanUpdate(
          DragUpdateDetails(
            globalPosition: const Offset(120, 640),
            delta: const Offset(0, 540),
          ),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        expect(scrollService.autoScrollEdgeOffsets, isNotEmpty);
        expect(
          scrollService.autoScrollEdgeOffsets.last,
          appFlowyEditorAutoScrollDragEdgeOffset,
        );
        expect(
          appFlowyEditorAutoScrollDragEdgeOffset,
          lessThan(appFlowyEditorAutoScrollEdgeOffset),
          reason:
              'the drag threshold must be smaller than the comfortable margin',
        );
      },
    );

    testWidgets(
      'the direction is derived from the pointer position',
      (tester) async {
        await buildEditor(tester);

        final selectionService = editorState.service.selectionService;

        selectionService.onPanStart(
          DragStartDetails(globalPosition: const Offset(120, 400)),
          MobileSelectionDragMode.leftSelectionHandle,
        );
        selectionService.onPanUpdate(
          DragUpdateDetails(
            globalPosition: const Offset(120, 640),
            delta: const Offset(0, 240),
          ),
          MobileSelectionDragMode.leftSelectionHandle,
        );

        expect(scrollService.autoScrollDirections, isNotEmpty);
        expect(
          scrollService.autoScrollDirections.last,
          isNull,
          reason:
              'the proxy rect is centered on the pointer, so the direction is '
              'derived from the position of the pointer and not from the type '
              'of the handle',
        );
      },
    );

    testWidgets('the auto scroll stops when the drag ends', (tester) async {
      await buildEditor(tester);

      final selectionService = editorState.service.selectionService;

      selectionService.onPanStart(
        DragStartDetails(globalPosition: const Offset(120, 100)),
        MobileSelectionDragMode.rightSelectionHandle,
      );
      selectionService.onPanUpdate(
        DragUpdateDetails(
          globalPosition: const Offset(120, 640),
          delta: const Offset(0, 540),
        ),
        MobileSelectionDragMode.rightSelectionHandle,
      );

      expect(scrollService.stopAutoScrollCount, 0);

      selectionService.onPanEnd(
        DragEndDetails(),
        MobileSelectionDragMode.rightSelectionHandle,
      );

      expect(
        scrollService.stopAutoScrollCount,
        1,
        reason: 'the document must not keep scrolling after the drag ended',
      );
    });

    testWidgets(
      'the auto scroll keeps running while the pointer is held still',
      (tester) async {
        final document = Document.blank()
          ..insert([0], [paragraphNode(text: 'Hello World!')]);
        editorState = EditorState(document: document);
        editorState.selection = Selection.collapsed(Position(path: [0, 0]));

        final scrollController = ScrollController();

        await tester.buildAndPump(
          Provider<EditorState>.value(
            value: editorState,
            child: Provider<EditorScrollController>.value(
              value: EditorScrollController(
                editorState: editorState,
                shrinkWrap: true,
                scrollController: scrollController,
              ),
              child: _RecordingScrollService(
                key: editorState.service.scrollServiceKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: const SizedBox(height: 3000),
                      ),
                    ),
                    MobileSelectionServiceWidget(
                      key: editorState.service.selectionServiceKey,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // attach the auto scroller to the scrollable, so that the auto scroll
        // is able to scroll the document for real.
        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        editorState.updateAutoScroller(scrollableState);

        final scrollService = tester.state<_RecordingScrollServiceState>(
          find.byType(_RecordingScrollService),
        );
        scrollService.autoScroller = editorState.autoScroller;

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        final selectionService = editorState.service.selectionService;

        selectionService.onPanStart(
          DragStartDetails(globalPosition: Offset(50, viewport.center.dy)),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        // the pointer is held at the bottom of the viewport and it is not
        // moved any further
        selectionService.onPanUpdate(
          DragUpdateDetails(
            globalPosition: Offset(50, viewport.bottom - 20),
          ),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final offsetAfterFirstFrames = scrollController.offset;

        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final offsetAfterSecondFrames = scrollController.offset;

        editorState.autoScroller?.stopAutoScroll();
        await tester.pumpAndSettle();

        expect(
          offsetAfterFirstFrames,
          greaterThan(0),
          reason: 'the document should have scrolled towards the bottom edge',
        );
        expect(
          offsetAfterSecondFrames,
          greaterThan(offsetAfterFirstFrames + 10),
          reason:
              'the document should keep scrolling while the pointer is held '
              'still at the edge of the viewport',
        );
      },
    );

    testWidgets(
      'the drag mode is kept in the extra info when the drag ends',
      (tester) async {
        await buildEditor(tester);

        final selectionService = editorState.service.selectionService;

        selectionService.onPanStart(
          DragStartDetails(globalPosition: const Offset(120, 100)),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        // the selection service writes the drag mode into the extra info
        // whenever the selection changes during a drag
        selectionService.updateSelection(
          Selection.collapsed(Position(path: [0, 0], offset: 3)),
        );

        expect(
          isMobileSelectionDragging(editorState.selectionExtraInfo),
          isTrue,
        );

        selectionService.onPanEnd(
          DragEndDetails(),
          MobileSelectionDragMode.rightSelectionHandle,
        );

        expect(
          isMobileSelectionDragging(editorState.selectionExtraInfo),
          isTrue,
          reason: 'the tail of a drag must be recognizable, otherwise the '
              'selection would be scrolled into a comfortable position right '
              'after the user released the handle',
        );
      },
    );
  });

  group('isMobileSelectionDragging', () {
    test('is false when there is no drag mode', () {
      expect(isMobileSelectionDragging(null), isFalse);
      expect(isMobileSelectionDragging({}), isFalse);
    });

    test('is false when the drag mode is none', () {
      expect(
        isMobileSelectionDragging({
          selectionDragModeKey: MobileSelectionDragMode.none,
        }),
        isFalse,
      );
    });

    test('is true while a handle is dragged', () {
      expect(
        isMobileSelectionDragging({
          selectionDragModeKey: MobileSelectionDragMode.leftSelectionHandle,
        }),
        isTrue,
      );
      expect(
        isMobileSelectionDragging({
          selectionDragModeKey: MobileSelectionDragMode.rightSelectionHandle,
        }),
        isTrue,
      );
      expect(
        isMobileSelectionDragging({
          selectionDragModeKey: MobileSelectionDragMode.cursor,
        }),
        isTrue,
      );
    });
  });
}
