import 'package:fl_local_notification/src/character.dart';
import 'package:fl_local_notification/src/extensions.dart';
import 'package:fl_local_notification/src/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final selectNotificationSubject = BehaviorSubject<String?>();

class LocalNotification {
  static final LocalNotification _singleton = LocalNotification._internal();

  static const _androidNotificationDetails = AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');

  LocalNotification._internal();

  factory LocalNotification() => _singleton;

  void initialize({String iconNotification = 'ic_notification'}) async {
    if (!kIsWeb) {
      await configureLocalTimeZone();
      _initializeLocalNotificationPlugin(iconNotification);
    }
  }

  Future<void> _initializeLocalNotificationPlugin(
      String iconNotification) async {
    final androidSettings = AndroidInitializationSettings(iconNotification);

    final iOSSettings = DarwinInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });

    final initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) async {
      debugPrint('notification payload: ${notificationResponse.payload}');

      selectNotificationSubject.add(notificationResponse.payload);
    });
  }

  void requestiOSPermissions() async {
    if (!kIsWeb) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required DateTime schedule,
    required String title,
    required String body,
  }) async {
    final howLongFromNow = DateTime.now().difference(schedule).abs();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(howLongFromNow),
        const NotificationDetails(android: _androidNotificationDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> addNotification(
      {required String id,
      required DateTime schedule,
      required String title,
      required String body}) async {
    if (!kIsWeb) {
      const platformChannelSpecifics =
          NotificationDetails(android: _androidNotificationDetails);

      final notificationId = Character.getInteger(id);

      if (schedule.isSameDate(DateTime.now())) {
        await flutterLocalNotificationsPlugin.show(
            notificationId, title, body, platformChannelSpecifics);
      } else {
        if (schedule.isAfter(DateTime.now())) {
          await _scheduleNotification(
              id: notificationId,
              schedule: schedule.setToSixHours,
              title: title,
              body: body);
        }
      }
    }
  }

  Future<void> cancelNotification(String id) async {
    if (!kIsWeb) {
      await flutterLocalNotificationsPlugin.cancel(Character.getInteger(id));
    }
  }
}
