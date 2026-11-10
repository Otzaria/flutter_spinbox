import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon size participates in theme equality and hash code', () {
    const small = SpinBoxThemeData(iconSize: 16);
    const large = SpinBoxThemeData(iconSize: 32);
    const same = SpinBoxThemeData(iconSize: 16);

    expect(small, equals(same));
    expect(small.hashCode, same.hashCode);
    expect(small, isNot(equals(large)));
    expect(small.hashCode, isNot(large.hashCode));
  });

  testWidgets('no empty slots without buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinBox(showButtons: false, value: 10),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    final decoration = field.decoration;
    expect(decoration, isNotNull);
    expect(decoration!.prefix, isNull);
    expect(decoration.suffix, isNull);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('custom decorations survive hidden buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinBox(
            showButtons: false,
            decoration: const InputDecoration(
              prefix: Text('before'),
              suffix: Text('after'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('before'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });
}
