import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timezone/data/latest.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  Future<void> initNotificationsPlugin() async {
    initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  NotificationDetails getNotificationDetails(EntryType type) {
    Color notificationColor = Colors.white;
    switch (type) {
      case EntryType.event:
        const Color.fromRGBO(50, 162, 176, 1);
        break;
      case EntryType.task:
        const Color.fromARGB(255, 235, 254, 255);
        break;
      case EntryType.reminder:
        const Color.fromRGBO(0, 78, 82, 1);
        break;
    }
    ;
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.timescape',
      channelDescription: 'TimeScape Notification Channel',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      color: notificationColor,
    );
    return NotificationDetails(android: androidNotificationDetails);
  }
}
