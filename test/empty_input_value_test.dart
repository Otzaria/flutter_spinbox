import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final cupertino in [false, true]) {
    final name = cupertino ? 'Cupertino' : 'Material';

    Widget app({
      required ValueChanged<double> onChanged,
      required FocusNode focusNode,
      bool Function(double)? canChange,
      double value = 5,
    }) {
      if (cupertino) {
        return CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoSpinBox(
              min: -10,
              value: value,
              emptyValue: 0,
              decimals: 2,
              focusNode: focusNode,
              canChange: canChange,
              onChanged: onChanged,
            ),
          ),
        );
      }
      return MaterialApp(
        home: Scaffold(
          body: SpinBox(
            min: -10,
            value: value,
            emptyValue: 0,
            decimals: 2,
            focusNode: focusNode,
            canChange: canChange,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('$name clears to the opted-in value and retains it on blur', (
      tester,
    ) async {
      final changes = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(app(onChanged: changes.add, focusNode: focus));

      final field = find.byType(EditableText);
      await tester.enterText(field, '');
      await tester.pump();
      expect(changes, <double>[0]);

      focus.unfocus();
      await tester.pump();
      expect(tester.widget<EditableText>(field).controller.text, '0.00');
      expect(changes, <double>[0]);
    });

    testWidgets('$name controlled input inserts into the cleared field', (
      tester,
    ) async {
      double value = 5;
      final changes = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) => app(
          value: value,
          focusNode: focus,
          onChanged: (next) {
            changes.add(next);
            setState(() => value = next);
          },
        ),
      ));

      final field = find.byType(EditableText);
      await tester.enterText(field, '');
      await tester.pump();
      final editing = tester.widget<EditableText>(field).controller.value;
      final caret = editing.selection.start;
      tester.testTextInput.updateEditingValue(editing.copyWith(
        text: editing.text.replaceRange(caret, editing.selection.end, '2'),
        selection: TextSelection.collapsed(offset: caret + 1),
      ));
      await tester.pump();

      expect(value, 2);
      expect(changes, <double>[0, 2]);
      expect(editing.text, isEmpty);
      expect(
          double.parse(tester.widget<EditableText>(field).controller.text), 2);
    });

    testWidgets('$name can replace a cleared value without restoring it', (
      tester,
    ) async {
      final changes = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(app(onChanged: changes.add, focusNode: focus));

      final field = find.byType(EditableText);
      await tester.enterText(field, '');
      await tester.pump();
      await tester.enterText(field, '8');
      await tester.pump();
      focus.unfocus();
      await tester.pump();

      expect(changes, <double>[0, 8]);
      expect(tester.widget<EditableText>(field).controller.text, '8');
    });

    testWidgets(
      '$name empty value does not reinterpret partial numeric input',
      (tester) async {
        final changes = <double>[];
        final focus = FocusNode();
        addTearDown(focus.dispose);
        await tester.pumpWidget(app(onChanged: changes.add, focusNode: focus));

        final field = find.byType(EditableText);
        for (final text in ['-', '.', '-.']) {
          await tester.enterText(field, text);
          await tester.pump();
          expect(changes, isEmpty);
        }
        focus.unfocus();
        await tester.pump();
        expect(tester.widget<EditableText>(field).controller.text, '5.00');
      },
    );

    testWidgets('$name respects canChange when clearing', (tester) async {
      final changes = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        app(
          onChanged: changes.add,
          focusNode: focus,
          canChange: (value) => value != 0,
        ),
      );

      final field = find.byType(EditableText);
      await tester.enterText(field, '');
      await tester.pump();
      focus.unfocus();
      await tester.pump();

      expect(changes, isEmpty);
      expect(tester.widget<EditableText>(field).controller.text, '5.00');
    });
  }
}
