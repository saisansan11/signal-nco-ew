// Basic Flutter widget test for Signal NCO EW App

import 'package:flutter_test/flutter_test.dart';
import 'package:signal_nco_ew/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SignalNCOEWApp());

    // Verify that splash screen is shown
    expect(find.text('EW NCO Training'), findsOneWidget);
  });
}
