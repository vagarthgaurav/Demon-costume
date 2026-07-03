import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demon_app/main.dart';

void main() {
  testWidgets('Home screen shows LED, battery and wing tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const DemonApp());
    await tester.pump();

    expect(find.text('DEMON BOARD'), findsOneWidget);
    expect(find.text('CONNECT'), findsOneWidget);
    expect(find.text('LED'), findsOneWidget);
    expect(find.text('BATTERY'), findsOneWidget);
    expect(find.text('WINGS'), findsOneWidget);
    // App-bar battery badges are icon-only, differentiated by device glyph.
    expect(find.byIcon(Icons.flight_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_remote_outlined), findsOneWidget);
  });
}
