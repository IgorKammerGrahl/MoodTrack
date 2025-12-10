import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodtrack/widgets/mood_button.dart';

void main() {
  testWidgets('MoodButton displays correct label and handles tap', (
    WidgetTester tester,
  ) async {
    // Define test variables
    const String label = 'Confirmar';
    bool wasPressed = false;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodButton(
            label: label,
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    // Verify label is present
    expect(find.text(label), findsOneWidget);

    // Verify tapping
    await tester.tap(find.byType(MoodButton));
    await tester.pump();

    // Verify callback was called
    expect(wasPressed, true);
  });

  testWidgets('MoodButton shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodButton(label: 'Entrar', isLoading: true, onPressed: () {}),
        ),
      ),
    );

    // Verify CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Verify Text is NOT present (or at least not visible standardly)
    // The implementation switches child, so text should be gone
    expect(find.text('Entrar'), findsNothing);
  });
}
