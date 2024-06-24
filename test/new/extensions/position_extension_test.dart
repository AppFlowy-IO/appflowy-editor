//----
import 'dart:collection';
import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';

/// From test
//----
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/gestures/drag_details.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('position_extendion.dart', () {
    late EditorState editorState;
    late AppFlowySelectionService appFlowySelectionService;
    // late final List<List<int>> pathListListFromTest;
    late Position p1;
    late Position p2;
    Offset offs1 = const Offset(3, 0);
    Offset offs2 = const Offset(0, 0);
    Position invalidPosition = Position.invalid();
    late List<Rect> rectsW;
    // late final double offsDouble1;
    // late final double offsDouble2;

    setUp(() {
      final nod = Node(type: "node", attributes: {}, children: LinkedList());
      final doc = Document(root: nod);
      // pathListListFromTest = [
      //   [0, 1, 2],
      //   [0, 0, 7, 8, 9],
      //   [999, 0, 77, 08, 9],
      //   [0, 3],
      //   [0],
      //   []
      // ];
      // offs1 = const Offset(3, 0);
      // offs2 = const Offset(0, 0);
      p1 = Position(path: [0], offset: 5);
      p2 = Position(path: [0], offset: 5);
      // offsDouble1 = 12;
      // offsDouble2 = 0;
      rectsW = [
        Rect.zero,
        Rect.largest,
        Rect.fromPoints(offs1, offs2),
      ];
      editorState = EditorState(document: doc);
      appFlowySelectionService = MockAppFlowySelectionService();
    });

    test(
        'Position.invalid 1 extension -> .moveVertical = { upwards: false, checkedParagraphStep: true } ',
        () {
      final invalidPosition = Position.invalid();
      invalidPosition.moveVertical(
        editorState,
        upwards: false,
        checkedParagraphStep: true,
      );
      // invalidPosition.moveVertical(editorState, upwards: false, checkedParagraphStep: false);
      // invalidPosition.moveVertical(editorState, upwards: true, checkedParagraphStep: true);
      expect(invalidPosition.path, [-1]);
      expect(invalidPosition.offset, -1);
    });

    test(
        'Position.invalid 2 extension -> .moveVertical = { upwards: true, checkedParagraphStep: true } ',
        () {
      // final invalidPosition = Position.invalid();
      // invalidPosition.moveVertical(editorState, upwards: false, checkedParagraphStep: true);
      // invalidPosition.moveVertical(editorState, upwards: false, checkedParagraphStep: false);
      invalidPosition.moveVertical(
        editorState,
        upwards: true,
        checkedParagraphStep: true,
      );
      expect(invalidPosition.path, [-1]);
      expect(invalidPosition.offset, -1);
    });

    test(
        'Position.invalid 3 extension -> .moveVertical = { upwards: false, checkedParagraphStep: false } ',
        () {
      // final invalidPosition = Position.invalid();
      // invalidPosition.moveVertical(editorState, upwards: false, checkedParagraphStep: true);
      invalidPosition.moveVertical(
        editorState,
        upwards: false,
        checkedParagraphStep: false,
      );
      // invalidPosition.moveVertical(editorState, upwards: true, checkedParagraphStep: true);
      expect(invalidPosition.path, [-1]);
      expect(invalidPosition.offset, -1);
    });

    test('Position extension -> getPosition 1', () {
      p1.getPosition(offs1, appFlowySelectionService);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });

    test('Position extension -> getPosition 2', () {
      p1.getPosition(offs2, appFlowySelectionService);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> getPosition 3', () {
      p1.getPosition(
        offs1,
        appFlowySelectionService,
        checkedParagraphStep: true,
      );

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });

    test('Position extension -> offsetGet 1', () {
      p1.offsetGet(false, rectsW, upwards: true);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 2', () {
      p1.offsetGet(false, rectsW, upwards: false);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 3', () {
      p1.offsetGet(true, rectsW, upwards: false);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 4', () {
      p1.offsetGet(true, rectsW, upwards: true);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });

    ///////////////
    ///
    ///

    test('Position extension -> getPosition 1', () {
      p2.getPosition(offs1, appFlowySelectionService);

      expect(p1 == p2, true);
      expect(
        p1.hashCode == p2.hashCode,
        true,
      );
    });

    test('Position extension -> getPosition 2', () {
      p2.getPosition(offs2, appFlowySelectionService);

      expect(p1 == p2, true);
      expect(
        p1.hashCode == p2.hashCode,
        true,
      );
    });
    test('Position extension -> getPosition 3', () {
      p2.getPosition(
        offs1,
        appFlowySelectionService,
        checkedParagraphStep: true,
      );

      expect(p1 == p2, true);
      expect(
        p1.hashCode == p2.hashCode,
        true,
      );
    });

    test('Position extension -> offsetGet 1', () {
      p2.offsetGet(false, rectsW, upwards: true);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 2', () {
      p2.offsetGet(false, rectsW, upwards: false);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 3', () {
      p2.offsetGet(true, rectsW, upwards: false);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
    test('Position extension -> offsetGet 4', () {
      p2.offsetGet(true, rectsW, upwards: true);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });
  });
}

class MockAppFlowySelectionService implements AppFlowySelectionService {
  @override
  void clearCursor() {
    // implement clearCursor
  }

  @override
  void clearSelection() {
    // implement clearSelection
  }

  @override
  // implement currentSelectedNodes
  List<Node> get currentSelectedNodes => throw UnimplementedError();

  @override
  // implement currentSelection
  ValueNotifier<Selection?> get currentSelection => throw UnimplementedError();

  @override
  Node? getNodeInOffset(Offset offset) {
    // implement getNodeInOffset
    throw UnimplementedError();
  }

  @override
  Position? getPositionInOffset(Offset offset) {
    // implement getPositionInOffset
    return null;
  }

  @override
  void onPanEnd(DragEndDetails details, MobileSelectionDragMode mode) {
    // implement onPanEnd
  }

  @override
  Selection? onPanStart(
    DragStartDetails details,
    MobileSelectionDragMode mode,
  ) {
    // implement onPanStart
    throw UnimplementedError();
  }

  @override
  Selection? onPanUpdate(
    DragUpdateDetails details,
    MobileSelectionDragMode mode,
  ) {
    // implement onPanUpdate
    throw UnimplementedError();
  }

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    // implement registerGestureInterceptor
  }

  @override
  // implement selectionRects
  List<Rect> get selectionRects => throw UnimplementedError();

  @override
  void unregisterGestureInterceptor(String key) {
    // implement unregisterGestureInterceptor
  }

  @override
  void updateSelection(Selection? selection) {
    // implement updateSelection
  }
}
