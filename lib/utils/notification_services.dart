import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:plant_tracker/databases/plant.dart'; // Adjust import as needed

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request notification permission
    await _requestNotificationPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Create a notification channel for Android 8.0 (API level 26) and above
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'plant_tracker_channel',
      'Plant Tracker Notifications',
      description: 'Notifications for plant tracking and watering',
      importance: Importance.max,
    );

    // Initialize the notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin().createNotificationChannel(channel);

    // Initialize notifications with the specified settings
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request notification permission
  static Future<bool> _requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      print('Notification permission already granted');
      return true;
    }

    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
      return true;
    } else {
      print('Notification permission denied');
      return false;
    }
  }

  // Generic notification method
  static Future<void> showNotification({
    String title = 'Plant Tracker',
    String body = 'You have a new notification!',
  }) async {
    // Ensure permission is granted
    bool permissionGranted = await _requestNotificationPermission();
    if (!permissionGranted) {
      print('Cannot show notification - permission not granted');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'plant_tracker_channel',
      'Plant Tracker Notifications',
      channelDescription: 'General notifications for Plant Tracker',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      print("Attempting to show notification");
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        title,
        body,
        platformChannelSpecifics,
      );
      print("Notification shown successfully");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  static Future<void> showPlantNotification({
    required BuildContext context,
    required Plant plant,
  }) async {
    // Ensure permission is granted
    bool permissionGranted = await _requestNotificationPermission();
    if (!permissionGranted) {
      print('Cannot show notification - permission not granted');
      return;
    }

    // Customize the notification title and body using the Plant instance
    String title = 'Water Reminder for ${plant.name}';
    String body =
        'Next watering times: ${plant.wateringTimes.map((time) => time.format(context)).join(', ')}';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'plant_tracker_channel',
      'Plant Tracker Notifications',
      channelDescription: 'General notifications for Plant Tracker',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      print("Attempting to show notification for plant: ${plant.name}");
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        title,
        body,
        platformChannelSpecifics,
      );
      print("Notification shown successfully for plant: ${plant.name}");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  // Schedule daily notifications for a specific plant
  static Future<void> scheduleDailyNotification(Plant plant) async {
    // Cancel any existing notifications for this plant first
    await cancelPlantNotifications(plant.id!);

    // Schedule a notification for each watering time
    for (int i = 0; i < plant.wateringTimes.length; i++) {
      TimeOfDay wateringTime = plant.wateringTimes[i];

      print(_nextInstanceOfTime(wateringTime));
      // Create a unique notification ID for this plant and time
      int notificationId = plant.id! * 10 + i;

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Watering Time',
        'Time to water your plant: ${plant.name}',
        _nextInstanceOfTime(wateringTime),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'plant_tracker_channel',
            'Plant Watering Notifications',
            channelDescription: 'Daily plant watering reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Helper method to calculate next occurrence of a specific time
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Cancel notifications for a specific plant
  static Future<void> cancelPlantNotifications(int plantId) async {
    // Cancel all notifications with IDs that match this plant
    for (int i = 0; i < 10; i++) {
      await _flutterLocalNotificationsPlugin.cancel(plantId * 10 + i);
    }
  }

  // Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
