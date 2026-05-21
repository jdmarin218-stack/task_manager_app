import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/task_model.dart';

/// Fuente de datos local usando SharedPreferences
class TaskLocalDatasource {
  static const String _tasksKey = 'tasks_list';

  /// Leer todas las tareas guardadas
  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    final List<dynamic> tasksList = jsonDecode(tasksJson);
    return tasksList
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Guardar la lista completa de tareas
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson =
        jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
}
