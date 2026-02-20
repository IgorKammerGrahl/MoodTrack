import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodtrack/main.dart';
import 'package:moodtrack/services/storage_service.dart';
import 'package:moodtrack/services/auth_service.dart';
import 'package:moodtrack/controllers/auth_controller.dart';
import 'package:moodtrack/controllers/mood_controller.dart';
import 'package:moodtrack/controllers/settings_controller.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Use a phone-sized surface to avoid layout overflow in test harness
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Setup DI like main() does
    SharedPreferences.setMockInitialValues({});
    await Get.putAsync(() => StorageService().init());
    Get.put(AuthService());
    Get.put(AuthController());
    Get.put(MoodController());
    Get.put(SettingsController(), permanent: true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodTrackApp());
    await tester.pumpAndSettle();

    // App should render without crashing (layout overflows are OK in test)
    // Verify a widget tree was built
    expect(find.byType(MaterialApp), findsOneWidget);

    // Cleanup
    Get.reset();
  });
}
