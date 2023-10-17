import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('image_node_builder.dart', () {
    const text = 'Welcome to Appflowy 😁';
    const url =
        'https://images.unsplash.com/photo-1682961941145-e73336a53bc6?dl=katsuma-tanaka-cWpkMDSQbWQ-unsplash.jpg';
    testWidgets('render image node', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(url: url),
          )
          ..addParagraph(initialText: text);
        await editor.startTesting();
        await tester.pumpAndSettle();

        expect(editor.documentRootLen, 3);
        expect(find.byType(Image), findsOneWidget);

        await editor.dispose();
      });
    });

    testWidgets('cannot see action menu when not editable', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(url: url),
          )
          ..addParagraph(initialText: text);

        await editor.startTesting(
          editable: false,
          wrapper: (child) => SingleChildScrollView(
            child: child,
          ),
        );
        await tester.pumpAndSettle();

        expect(editor.documentRootLen, 3);
        expect(find.byType(Image), findsOneWidget);

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);

        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.byType(Image)));
        await tester.pumpAndSettle();

        expect(find.byType(EditorSvg), findsNothing);

        await editor.dispose();
      });
    });

    testWidgets('can see action menu when editable', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(url: url),
          )
          ..addParagraph(initialText: text);

        await editor.startTesting();
        await tester.pumpAndSettle();

        expect(editor.documentRootLen, 3);
        expect(find.byType(Image), findsOneWidget);

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);

        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.byType(Image)));
        await tester.pumpAndSettle();

        // expect(find.byType(FlowySvg), findsWidgets);

        await editor.dispose();
      });
    });

    testWidgets('render image align', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(
              url: url,
              align: 'left',
              width: 100,
            ),
          )
          ..addNode(
            imageNode(
              url: url,
              align: 'center',
              width: 100,
            ),
          )
          ..addNode(
            imageNode(
              url: url,
              align: 'right',
              width: 100,
            ),
          )
          ..addParagraph(initialText: text);
        await editor.startTesting();
        await tester.pumpAndSettle();

        expect(editor.documentRootLen, 5);
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsNWidgets(3));

        final editorFinder = find.byType(AppFlowyEditor);
        final editorRect = tester.getRect(editorFinder);

        final leftImageRect = tester.getRect(imageFinder.at(0));
        expect(
          leftImageRect.left,
          editor.editorState.editorStyle.padding.left,
        );
        final rightImageRect = tester.getRect(imageFinder.at(2));
        expect(
          rightImageRect.right,
          editorRect.right - editor.editorState.editorStyle.padding.right,
        );
        final centerImageRect = tester.getRect(imageFinder.at(1));
        expect(
          centerImageRect.left,
          (leftImageRect.left + rightImageRect.left) / 2.0,
        );
        expect(leftImageRect.size, centerImageRect.size);
        expect(rightImageRect.size, centerImageRect.size);

        // final leftImageNode = editor.document.nodeAtPath([1]);

        // expect(editor.runAction(1, leftImageNode!), true); // align center
        // await tester.pump();
        // expect(
        //   tester.getRect(imageFinder.at(0)).left,
        //   centerImageRect.left,
        // );

        // expect(editor.runAction(2, leftImageNode), true); // align right
        // await tester.pump();
        // expect(
        //   tester.getRect(imageFinder.at(0)).right,
        //   rightImageRect.right,
        // );
      });
    });

    testWidgets('render image copy', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(url: url),
          )
          ..addParagraph(initialText: text);
        await editor.startTesting();

        expect(editor.documentRootLen, 3);
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);

        // final node = editor.document.nodeAtPath([1]);

        // expect(editor.runAction(3, imageNode!), true); // copy
        // await tester.pump();
      });
    });

    testWidgets('render image delete', (tester) async {
      mockNetworkImagesFor(() async {
        final editor = tester.editor
          ..addParagraph(initialText: text)
          ..addNode(
            imageNode(url: url),
          )
          ..addParagraph(initialText: text);
        await editor.startTesting();
        await tester.pumpAndSettle();

        expect(editor.documentRootLen, 3);
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsNWidgets(1));

        // final node = editor.document.nodeAtPath([1]);
        // expect(editor.runAction(4, imageNode!), true); // delete

        // await tester.pump(const Duration(milliseconds: 100));
        // expect(editor.documentRootLen, 3);
        // expect(find.byType(Image), findsNWidgets(1));
      });
    });
  });
}
