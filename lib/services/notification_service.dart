import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); 

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 🔴 ERROR FIX: 'settings:' likhna zaroori ho gaya hai
    await _notificationsPlugin.initialize(settings: settings);
  }

  static Future<void> scheduleNotification({required int id, required String title, required String body}) async {
    // 🔴 ERROR FIX: Har cheez se pehle uska tag (id:, title:, body: waghera) likhna ab lazmi hai
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(hours: 12)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel_id',
          'Todo Notifications',
          channelDescription: 'Reminders for todo tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Naye version se 'uiLocalNotificationDateInterpretation' khatam kar diya gaya hai, isliye us line ko hata diya.
    );
  }
}