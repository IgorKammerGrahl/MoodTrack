import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for preferences (notifications, accessibility) and chat history.
/// Mood CRUD, sync, and auth logic have been extracted to repositories.
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // --- Notification Preferences ---

  static const String _keyDailyReminderEnabled = 'daily_reminder_enabled';
  static const String _keyDailyReminderTime = 'daily_reminder_time'; // "HH:mm"
  static const String _keyWeeklyInsightEnabled = 'weekly_insight_enabled';
  static const String _keyWeeklyInsightDay =
      'weekly_insight_day'; // 1-7 (Mon-Sun)

  Future<void> saveNotificationPreferences({
    required bool dailyEnabled,
    required String dailyTime,
    required bool weeklyEnabled,
    required int weeklyDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyReminderEnabled, dailyEnabled);
    await prefs.setString(_keyDailyReminderTime, dailyTime);
    await prefs.setBool(_keyWeeklyInsightEnabled, weeklyEnabled);
    await prefs.setInt(_keyWeeklyInsightDay, weeklyDay);
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dailyEnabled': prefs.getBool(_keyDailyReminderEnabled) ?? false,
      'dailyTime': prefs.getString(_keyDailyReminderTime) ?? '20:00',
      'weeklyEnabled': prefs.getBool(_keyWeeklyInsightEnabled) ?? false,
      'weeklyDay': prefs.getInt(_keyWeeklyInsightDay) ?? DateTime.sunday,
    };
  }

  // --- Accessibility Preferences ---

  static const String _keyFontSizeScale = 'font_size_scale';
  static const String _keyHighContrast = 'high_contrast';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyVisualDifficulty = 'visual_difficulty';

  Future<void> saveAccessibilityPreferences({
    required double fontSizeScale,
    required bool highContrast,
    required bool darkMode,
    required bool visualDifficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSizeScale, fontSizeScale);
    await prefs.setBool(_keyHighContrast, highContrast);
    await prefs.setBool(_keyDarkMode, darkMode);
    await prefs.setBool(_keyVisualDifficulty, visualDifficulty);
  }

  Future<Map<String, dynamic>> getAccessibilityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSizeScale': prefs.getDouble(_keyFontSizeScale) ?? 1.0,
      'highContrast': prefs.getBool(_keyHighContrast) ?? false,
      'darkMode': prefs.getBool(_keyDarkMode) ?? false,
      'visualDifficulty': prefs.getBool(_keyVisualDifficulty) ?? false,
    };
  }

  // --- Chat History ---

  String _getChatHistoryKey(String userId) => 'chat_history_$userId';

  Future<void> saveChatHistory(String userId, List<dynamic> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getChatHistoryKey(userId);

    // Limit to last 50 messages
    final limitedMessages = messages.length > 50
        ? messages.sublist(messages.length - 50)
        : messages;

    final jsonList = limitedMessages.map((m) => m.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  Future<List<dynamic>> getChatHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getChatHistoryKey(userId);
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList;
  }
}
