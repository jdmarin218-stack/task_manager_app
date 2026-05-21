import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);
  }

  Future<void> showTaskCreatedNotification({required String title}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_created_channel',
      'Tareas creadas',
      channelDescription: 'Notificaciones al crear una nueva tarea',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Nueva tarea creada',
      body: title,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showDueDateReminderNotification({
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'due_date_channel',
      'Recordatorios',
      channelDescription: 'Tareas proximas a vencer',
      importance: Importance.max,
      priority: Priority.max,
    );
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Tarea proxima a vencer',
      body: '$taskTitle vence el ${dueDate.day}/${dueDate.month}/${dueDate.year}',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }
}
