import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:physio_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleWeeklyNotification() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if the notification has already been scheduled
  bool isNotificationScheduled =
      prefs.getBool('isNotificationScheduled') ?? false;

  if (!isNotificationScheduled) {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(days: 7));

    var androidDetails = AndroidNotificationDetails(
      'weekly_notifications_channel_id',
      'Weekly Notifications',
      channelDescription: 'This channel is used for weekly diet reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Diet Reminder',
      'Make sure you have a new diet plan!',
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Set the flag in SharedPreferences to prevent duplicate scheduling
    await prefs.setBool('isNotificationScheduled', true);
  } else {
    print("Notification is already scheduled.");
  }
}
