import 'package:flutter_test/flutter_test.dart';
import 'package:moodtrack/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodTrackApp());

    // Verify that the app starts with the Splash Screen showing "MoodTrack".
    expect(find.text('MoodTrack'), findsOneWidget);

    // Wait for splash screen timer (3 seconds) + small buffer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Should be on Home Screen now
    expect(find.text('Iniciar Check-in'), findsOneWidget);
  });
}
