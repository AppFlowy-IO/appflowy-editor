import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() async {
  testWidgetsWithLeakTracking(
    'memory leak',
    (tester) async {
      await tester.pumpWidget(const _NoMemoryLeaks());
      await tester.pumpAndSettle();
    },
    leakTesting: LeakTesting.settings.copyWith(
      ignore: false,
      leakDiagnosticConfig: const LeakDiagnosticConfig(
        collectStackTraceOnStart: true,
        collectRetainingPathForNotGCed: true,
      ),
      onLeaks: (leaks) {
        // dump the leaks
        for (final leak in leaks.all) {
          final stack =
              leak.context![ContextKeys.startCallstack]! as StackTrace;
          final stackInEditor = stack
              .toString()
              .split('\n')
              .where((stack) => stack.contains('package:appflowy_editor'))
              .join('\n');
          debugPrint('''
${leak.type} => ${leak.trackedClass}
$stackInEditor
-------------------------------------------------------------------------------
''');
        }
        expect(leaks.all, isEmpty);
      },
    ),
  );
}

class _NoMemoryLeaks extends StatefulWidget {
  const _NoMemoryLeaks();

  @override
  State<_NoMemoryLeaks> createState() => __NoMemoryLeaksState();
}

class __NoMemoryLeaksState extends State<_NoMemoryLeaks> {
  final editorState = EditorState.blank();

  @override
  void dispose() {
    editorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: AppFlowyEditor(
              editorState: editorState,
            ),
          ),
        ),
      ),
    );
  }
}
