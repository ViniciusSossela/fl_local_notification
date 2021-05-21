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

final selectNotificationSubject = BehaviorSubject<String>();

class LocalNotification {
  static final LocalNotification _singleton = LocalNotification._internal();

  static const _androidNotificationDetails = AndroidNotificationDetails(
      'channel_id', 'channel_name', 'channel_desc',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');

  LocalNotification._internal();

  factory LocalNotification() => _singleton;

  void initialize() async {
    if (!kIsWeb) {
      await configureLocalTimeZone();
      _initializeLocalNotificationPlugin();
    }
  }

  Future<void> _initializeLocalNotificationPlugin() async {
    final androidSettings = AndroidInitializationSettings('ic_notification');

    final iOSSettings = IOSInitializationSettings(onDidReceiveLocalNotification:
        (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });

    final initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
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
    @required int id,
    @required DateTime schedule,
    @required String title,
    @required String body,
  }) async {
    assert(id != null && schedule != null && title != null && body != null);

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
      {@required String id,
      @required DateTime schedule,
      @required String title,
      @required String body}) async {
    if (!kIsWeb) {
      assert(id != null && schedule != null && title != null && body != null);

      const platformChannelSpecifics =
          NotificationDetails(android: _androidNotificationDetails);

      if (schedule.isSameDate(DateTime.now())) {
        await flutterLocalNotificationsPlugin.show(
            Character.getInteger(id), title, body, platformChannelSpecifics);
      } else {
        if (schedule.isAfter(DateTime.now())) {
          await _scheduleNotification(
              id: Character.getInteger(id),
              schedule: schedule.setToSixHours,
              title: title,
              body: body);
        }
      }
    }
  }

  Future<void> cancelNotification(String id) async {
    if (!kIsWeb) {
      assert(id != null);
      await flutterLocalNotificationsPlugin.cancel(Character.getInteger(id));
    }
  }
}
