import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/src/spin_gesture.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({
  required ValueChanged<double> onStep,
  bool enabled = true,
  double step = 1,
  Duration interval = const Duration(milliseconds: 100),
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SpinGesture(
          enabled: enabled,
          step: step,
          interval: interval,
          onStep: onStep,
          child: const ColoredBox(
            color: Colors.blue,
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('canceling a long press stops repeated callbacks', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_harness(onStep: changes.add));

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SpinGesture)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
    expect(changes, isNotEmpty);

    await gesture.cancel();
    await tester.pump();
    final count = changes.length;
    await tester.pump(const Duration(seconds: 1));
    expect(changes, hasLength(count));
  });

  testWidgets('disabling while held stops the repeat timer', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_harness(onStep: changes.add));

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SpinGesture)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
    expect(changes, isNotEmpty);

    await tester.pumpWidget(_harness(onStep: changes.add, enabled: false));
    final count = changes.length;
    await tester.pump(const Duration(seconds: 1));
    expect(changes, hasLength(count));
    await gesture.up();
  });

  testWidgets('a changed step is used on the next long press', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_harness(onStep: changes.add, step: 1));
    await tester.pumpWidget(_harness(onStep: changes.add, step: 3));

    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SpinGesture)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 150));

    expect(changes, isNotEmpty);
    expect(changes.first, 3);
    await gesture.up();
  });

  testWidgets('zero repeat interval never creates a busy timer', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(
      _harness(onStep: changes.add, interval: Duration.zero),
    );
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(SpinGesture)));
    await tester.pump(kLongPressTimeout + const Duration(seconds: 1));
    expect(changes, isEmpty);
    await gesture.up();
  });
}
