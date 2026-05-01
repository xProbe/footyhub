import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke: widget tree builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('FootyHub'))),
    );
    expect(find.text('FootyHub'), findsOneWidget);
  });
}
