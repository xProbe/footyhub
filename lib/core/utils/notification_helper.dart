import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(settings: initializationSettings);
    } catch (e) {
      debugPrint("Notification init failed: $e");
    }
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint("Notification requestPermission failed: $e");
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'footyhub_channel',
        'FootyHub',
        channelDescription: 'Berita penting & pertandingan live',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint("Notification showNotification failed: $e");
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'footyhub_reminders',
        'FootyHub Reminders',
        channelDescription: 'Match schedules and reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        await showNotification(id: id, title: title, body: body);
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Notification scheduleNotification failed: $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint("Notification cancelNotification failed: $e");
    }
  }

  static Future<void> showTestNotification() async {
    await requestPermission();
    await showNotification(
      id: 999,
      title: 'FootyHub — Tes Notifikasi Instan',
      body: 'Notifikasi uji coba berhasil dikirim! Fitur pengingat siap digunakan.',
    );
  }
}
