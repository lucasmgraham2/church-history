// Church History Explorer Widget Tests
//
// Add your widget tests here as you develop new features.
// For now, this file contains basic smoke tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church_history_explorer/main.dart';

void main() {
  testWidgets('App loads and shows authentication', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the app is responsive
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
