import 'package:appflowy_editor/src/editor/util/property_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PropertyValueNotifier', () {
    test('notifies listeners on assignment even when value is unchanged', () {
      final notifier = PropertyValueNotifier<int>(1);
      var calls = 0;
      notifier.addListener(() => calls++);

      notifier.value = 1;
      notifier.value = 1;
      expect(calls, 2);
    });

    test('notifies listeners in registration order', () {
      final notifier = PropertyValueNotifier<int>(0);
      final order = <int>[];
      notifier.addListener(() => order.add(1));
      notifier.addListener(() => order.add(2));
      notifier.addListener(() => order.add(3));

      notifier.value = 1;
      expect(order, [1, 2, 3]);
    });

    test('removeListener stops further notifications', () {
      final notifier = PropertyValueNotifier<int>(0);
      var calls = 0;
      void listener() => calls++;
      notifier.addListener(listener);
      notifier.value = 1;
      notifier.removeListener(listener);
      notifier.value = 2;
      expect(calls, 1);
    });

    test('listener removed during dispatch is not called this round', () {
      final notifier = PropertyValueNotifier<int>(0);
      final order = <String>[];
      late VoidCallback bListener;
      void aListener() {
        order.add('a');
        notifier.removeListener(bListener);
      }
      bListener = () => order.add('b');
      notifier.addListener(aListener);
      notifier.addListener(bListener);

      notifier.value = 1;
      expect(order, ['a']);
      // After dispatch, b is fully removed.
      notifier.value = 2;
      expect(order, ['a', 'a']);
    });

    test('listener added during dispatch is deferred until next notify', () {
      final notifier = PropertyValueNotifier<int>(0);
      final order = <String>[];
      void late() => order.add('late');
      notifier.addListener(() {
        order.add('early');
        notifier.addListener(late);
      });

      notifier.value = 1;
      expect(order, ['early']);
      notifier.value = 2;
      expect(order, ['early', 'early', 'late']);
    });

    test('hasListeners reflects current registration', () {
      final notifier = PropertyValueNotifier<int>(0);
      void listener() {}
      expect(notifier.hasListeners, isFalse);
      notifier.addListener(listener);
      expect(notifier.hasListeners, isTrue);
      notifier.removeListener(listener);
      expect(notifier.hasListeners, isFalse);
    });

    test('removeListener is O(1) even at large listener counts', () {
      // Regression test for the original O(n²) dispose cost. We just make sure
      // a large registration / deregistration pass completes well within a
      // second; the ChangeNotifier-backed implementation took multiple seconds
      // for this workload (10k * 10k linear scans + array shifts).
      final notifier = PropertyValueNotifier<int>(0);
      const n = 20000;
      final listeners = <void Function()>[];
      for (var i = 0; i < n; i++) {
        // Each listener must be a distinct closure so Set semantics hold.
        void l() {}
        listeners.add(l);
        notifier.addListener(l);
      }

      final stopwatch = Stopwatch()..start();
      for (final l in listeners) {
        notifier.removeListener(l);
      }
      stopwatch.stop();
      expect(notifier.hasListeners, isFalse);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason:
            'Removing $n listeners should be O(n), not O(n^2). Took '
            '${stopwatch.elapsedMilliseconds} ms.',
      );
    });
  });
}
