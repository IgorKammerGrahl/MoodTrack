import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodtrack/main.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodTrackApp());

    // Verify that the app starts with the Splash Screen showing "MoodTrack" title or similar.
    // Note: Adjust the string to match exact text in your splash screen or home screen.
    // Based on previous checks, logic might show Onboarding or Home.

    // Allow splash screen to pass
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Just verify we are running and have some widgets
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
