import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material step and incomplete edit retain value', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinBox(
            autofocus: true,
            value: 5,
            onChanged: changes.add,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(changes, <double>[6]);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(changes, <double>[6]);

    final state = tester.state<SpinBoxState>(find.byType(SpinBox));
    state.focusNode.unfocus();
    await tester.pump();
    expect(state.value, 6);
    expect(state.controller.text, '6');
  });

  testWidgets('Cupertino step and bounds share value core', (tester) async {
    final changes = <double>[];
    Widget build(double max) => CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoSpinBox(
              value: 5,
              max: max,
              onChanged: changes.add,
            ),
          ),
        );

    await tester.pumpWidget(build(6));
    await tester.tap(find.byIcon(CupertinoIcons.plus_circled));
    await tester.pump();

    final state =
        tester.state<CupertinoSpinBoxState>(find.byType(CupertinoSpinBox));
    expect(state.value, 6);
    expect(changes, <double>[6]);

    await tester.pumpWidget(build(8));
    expect(state.value, 6);
    await tester.tap(find.byIcon(CupertinoIcons.plus_circled));
    await tester.pump();
    expect(state.value, 7);
    expect(changes, <double>[6, 7]);
  });

  testWidgets('Material theme works with hidden buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinBoxTheme(
            data: const SpinBoxThemeData(iconSize: 30),
            child: SpinBox(
              value: 3,
              showButtons: false,
              decoration: const InputDecoration(
                prefix: Text('before'),
                suffix: Text('after'),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(IconButton), findsNothing);
    expect(find.text('before'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });
  testWidgets('Material submits a keyboard action only once', (tester) async {
    final submissions = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinBox(
            autofocus: true,
            value: 7,
            onSubmitted: submissions.add,
          ),
        ),
      ),
    );
    await tester.showKeyboard(find.byType(SpinBox));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submissions, <double>[7]);
  });

  testWidgets('Cupertino Done submits only once', (tester) async {
    final submissions = <double>[];
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CupertinoSpinBox(
            autofocus: true,
            value: 7,
            onSubmitted: submissions.add,
          ),
        ),
      ),
    );
    await tester.showKeyboard(find.byType(CupertinoSpinBox));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submissions, <double>[7]);
  });
}
