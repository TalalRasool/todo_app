import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talal_todo/constants/app_prefs.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const welcomeNotificationId = 900001;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'todo_channel_id',
      'Todo Notifications',
      channelDescription: 'Reminders for todo tasks',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e) {
      debugPrint('Using the default timezone: $e');
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(settings: settings);

    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    try {
      await android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Exact alarm permission unavailable: $e');
    }
  }

  static Future<void> showWelcome(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(AppPrefs.notificationsEnabled) ?? true;
      if (!enabled) return;

      final android = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();

      final trimmed = name.trim();
      final title = trimmed.isEmpty ? 'Welcome' : 'Welcome, $trimmed';
      await _notificationsPlugin.show(
        id: welcomeNotificationId,
        title: title,
        body: title,
        notificationDetails: _details,
      );
    } catch (e) {
      debugPrint('Welcome notification failed: $e');
    }
  }

  static Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(hours: 12));

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      debugPrint('Exact reminder failed, trying an inexact reminder: $e');
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
      return false;
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Could not cancel reminder: $e');
    }
  }
}
