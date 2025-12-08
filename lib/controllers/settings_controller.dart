import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final DatabaseService _db = DatabaseService();
  final NotificationService _notificationService = Get.put(
    NotificationService(),
  );

  final RxBool isDarkMode = false.obs;

  // Notification State
  final RxBool dailyReminderEnabled = false.obs;
  final Rx<TimeOfDay> dailyReminderTime = TimeOfDay(hour: 20, minute: 0).obs;

  final RxBool weeklyInsightEnabled = false.obs;
  final RxInt weeklyInsightDay = DateTime.sunday.obs; // 1-7

  // Accessibility State
  final RxDouble fontSizeScale = 1.0.obs;
  final RxBool highContrast = false.obs;
  final RxBool visualDifficulty = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _notificationService.init();
    _notificationService.requestPermissions();
  }

  Future<void> _loadPreferences() async {
    // Notifications
    final notifPrefs = await _db.getNotificationPreferences();
    dailyReminderEnabled.value = notifPrefs['dailyEnabled'];
    weeklyInsightEnabled.value = notifPrefs['weeklyEnabled'];
    weeklyInsightDay.value = notifPrefs['weeklyDay'];

    final timeParts = (notifPrefs['dailyTime'] as String).split(':');
    dailyReminderTime.value = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Accessibility
    final accessPrefs = await _db.getAccessibilityPreferences();
    fontSizeScale.value = accessPrefs['fontSizeScale'];
    highContrast.value = accessPrefs['highContrast'];
    isDarkMode.value = accessPrefs['darkMode'];
    visualDifficulty.value = accessPrefs['visualDifficulty'];

    // Apply Theme
    _updateTheme();
  }

  Future<void> _savePreferences() async {
    await _db.saveNotificationPreferences(
      dailyEnabled: dailyReminderEnabled.value,
      dailyTime:
          '${dailyReminderTime.value.hour}:${dailyReminderTime.value.minute.toString().padLeft(2, '0')}',
      weeklyEnabled: weeklyInsightEnabled.value,
      weeklyDay: weeklyInsightDay.value,
    );

    await _db.saveAccessibilityPreferences(
      fontSizeScale: fontSizeScale.value,
      highContrast: highContrast.value,
      darkMode: isDarkMode.value,
      visualDifficulty: visualDifficulty.value,
    );
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _updateTheme();
    _savePreferences();
  }

  void updateFontSize(double value) {
    fontSizeScale.value = value;
    _savePreferences();
    Get.forceAppUpdate();
  }

  void toggleHighContrast(bool value) {
    highContrast.value = value;
    _updateTheme();
    _savePreferences();
  }

  void toggleVisualDifficulty(bool value) {
    visualDifficulty.value = value;
    if (value) {
      fontSizeScale.value = 1.2; // 120% font size
      highContrast.value = true;
    } else {
      fontSizeScale.value = 1.0;
      highContrast.value = false;
    }
    _updateTheme();
    _savePreferences();
  }

  void _updateTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    Get.forceAppUpdate();
  }

  // --- Notification Logic ---

  Future<void> toggleDailyReminder(bool value) async {
    dailyReminderEnabled.value = value;
    await _savePreferences();

    if (value) {
      await _notificationService.scheduleDailyReminder(dailyReminderTime.value);
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> updateDailyReminderTime(TimeOfDay time) async {
    dailyReminderTime.value = time;
    await _savePreferences();

    if (dailyReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(time);
    }
  }

  Future<void> toggleWeeklyInsight(bool value) async {
    weeklyInsightEnabled.value = value;
    await _savePreferences();

    if (value) {
      // Default time for weekly insight: 09:00 AM
      await _notificationService.scheduleWeeklyInsight(
        weeklyInsightDay.value,
        const TimeOfDay(hour: 9, minute: 0),
      );
    } else {
      await _notificationService.cancelWeeklyInsight();
    }
  }

  Future<void> updateWeeklyInsightDay(int day) async {
    weeklyInsightDay.value = day;
    await _savePreferences();

    if (weeklyInsightEnabled.value) {
      await _notificationService.scheduleWeeklyInsight(
        day,
        const TimeOfDay(hour: 9, minute: 0),
      );
    }
  }

  Future<void> exportData() async {
    Get.snackbar('Exportar', 'Dados exportados com sucesso (Simulado)');
  }

  Future<void> deleteAccount() async {
    Get.snackbar('Conta Deletada', 'Sua conta foi removida (Simulado)');
  }
}
