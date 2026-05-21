import 'dart:convert';

/// Prioridad de la tarea
enum TaskPriority { low, medium, high }

/// Estado de la tarea
enum TaskStatus { pending, inProgress, completed }

/// Modelo principal de tarea - implementación manual inmutable
class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
  });

  /// Crear copia con campos modificados
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Serializar a JSON para SharedPreferences
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  /// Deserializar desde JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: TaskStatus.values.byName(json['status']),
        priority: TaskPriority.values.byName(json['priority']),
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'])
            : null,
      );

  /// Serializar a String para SharedPreferences
  String toJsonString() => jsonEncode(toJson());

  /// Deserializar desde String
  factory TaskModel.fromJsonString(String source) =>
      TaskModel.fromJson(jsonDecode(source));
}
