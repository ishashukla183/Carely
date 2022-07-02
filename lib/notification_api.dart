import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
class NotificationAPI{
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future showNotifications({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    required TimeOfDay time,

}) async =>
      _notifications.zonedSchedule(id, title, body, _scheduleDaily(time),await notificationDetails(), payload: payload, androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,matchDateTimeComponents: DateTimeComponents.time );

  static Future notificationDetails() async{
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
      )
    );
  }
  static Future init({bool initScheduled = false}) async {
    tz.initializeTimeZones();
    final android =  const AndroidInitializationSettings('appicon');
    final settings = InitializationSettings(android: android);
    await _notifications.initialize(settings, onSelectNotification: (payload) async {
onNotifications.add(payload);
    });
  }
  static tz.TZDateTime _scheduleDaily(TimeOfDay time){
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Kolkata'));
    final scheduledDate = tz.TZDateTime(tz.getLocation('Asia/Kolkata'), now.year, now.month, now.day, time.hour , time.minute );
    if (kDebugMode) {
      print("scheduled date = " + scheduledDate.toString());
    }
    return scheduledDate.isBefore(now)? scheduledDate.add(Duration(days: 1)) : scheduledDate;

  }
}