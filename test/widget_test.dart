import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/app.dart';

void main() {
  testWidgets('FridgeIQ app renders with navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FridgeIQApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('FridgeIQ'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
  });
}
