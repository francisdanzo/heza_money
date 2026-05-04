import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service pour gérer les notifications locales
/// Envoie une notification chaque 1er du mois pour faire le bilan
class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Initialise le service de notifications
  Future<void> init() async {
    tz.initializeTimeZones();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // --- Configuration Linux ---
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    // --- Configuration Android ---
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // --- Configuration iOS ---
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // --- Fusion des configurations ---
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // --- Permission iOS ---
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // --- Planifier la notification mensuelle du 1er ---
    await _scheduleMonthlyBilanNotification();

    print('✅ Notifications Service initialisé');
  }

  /// Planifie une notification pour chaque 1er du mois à 9h
  Future<void> _scheduleMonthlyBilanNotification() async {
    // Calculer la prochaine occurrence du 1er du mois
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      1,
      9, // 9h00 du matin
      0,
    );

    // Si le 1er est passé, programmer pour le 1er du mois suivant
    if (scheduledDate.isBefore(now)) {
      final nextMonth = now.month == 12
          ? tz.TZDateTime(tz.local, now.year + 1, 1, 9, 0)
          : tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 9, 0);
      scheduledDate = nextMonth;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'heza_money_monthly',
      'Bilan mensuel',
      channelDescription: 'Rappel du bilan mensuel Heza Money',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      color: 0xFF0F6E56, // Couleur primaire
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxNotificationDetails =
        LinuxNotificationDetails(
      defaultActionName: 'Open',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      linux: linuxNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID de la notification
      '💚 Bilan mensuel Heza Money',
      'C\'est le jour de faire le point sur ton budget et tes objectifs !',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );

    print('📅 Notification mensuelle planifiée pour le 1er à 9h');
  }

  /// Envoie une notification simple immédiate
  Future<void> showNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'heza_money_general',
      'Notifications Heza Money',
      channelDescription: 'Notifications générales',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  /// Callback quand on tap une notification
  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Ici on peut naviguer vers un écran spécifique si nécessaire
    print('Notification tappée: ${notificationResponse.payload}');
  }
}
