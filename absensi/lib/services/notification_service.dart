import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Inisialisasi zona waktu
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      // Use the local timezone name, or default to Dili
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Dili'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await scheduleDailyReminders();
  }

  static Future<void> scheduleDailyReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    _scheduleDailyNotification(
      id: 1,
      title: 'Horas Tama',
      body: 'Tempu atu presensa tama dadersan! Keta haluha marka liman.',
      hour: 7,
      minute: 45,
    );

    _scheduleDailyNotification(
      id: 2,
      title: 'Horas Deskansa',
      body: 'Tempu atu marka presensa sai deskansa agora.',
      hour: 12,
      minute: 0,
    );

    _scheduleDailyNotification(
      id: 3,
      title: 'Horas Tama Lokraik',
      body: 'Tempu atu presensa tama fali lokraik!',
      hour: 13,
      minute: 15,
    );

    _scheduleDailyNotification(
      id: 4,
      title: 'Horas Sai',
      body: 'Tempu atu presensa sai/fila! Obrigadu ba servisu loron ohin nian.',
      hour: 17,
      minute: 30,
    );
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'absensi_channel',
          'Horas Presensa',
          channelDescription: 'Avisu tempu presensa loron-loron nian',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
