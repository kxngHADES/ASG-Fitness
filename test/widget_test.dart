// Basic smoke test: the app boots and shows its loading state without
// throwing. Deeper testing of the SQLite-backed screens needs a platform
// channel / ffi database stub, which is out of scope for this smoke test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asg_fitness/main.dart';

void main() {
  testWidgets('App boots and shows a loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const AsgFitnessApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
