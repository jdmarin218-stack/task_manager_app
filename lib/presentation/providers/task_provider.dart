import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/notification_service.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

/// Provider del datasource local
final taskDatasourceProvider = Provider<TaskLocalDatasource>(
  (ref) => TaskLocalDatasource(),
);

/// Provider del repositorio
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskDatasourceProvider)),
);

/// Notifier de la lista de tareas
class TaskNotifier extends AsyncNotifier<List<TaskModel>> {
  late TaskRepository _repository;

  @override
  Future<List<TaskModel>> build() async {
    _repository = ref.watch(taskRepositoryProvider);
    return _repository.getAllTasks();
  }

  Future<void> addTask({
    required String title,
    required String description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    await _repository.saveTask(task);
    await NotificationService().showTaskCreatedNotification(title: task.title);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == id);
    await _repository.updateTask(task.copyWith(status: status));
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
    ref.invalidateSelf();
    await future;
  }
}

/// Provider principal de tareas
final taskProvider =
    AsyncNotifierProvider<TaskNotifier, List<TaskModel>>(TaskNotifier.new);

/// Enum de filtros
enum TaskFilter { all, pending, inProgress, completed }

/// Notifier del filtro activo
class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) => state = filter;
}

/// Provider del filtro
final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

/// Provider de tareas filtradas
final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(taskProvider);

  return tasks.whenData((list) {
    switch (filter) {
      case TaskFilter.all:
        return list;
      case TaskFilter.pending:
        return list.where((t) => t.status == TaskStatus.pending).toList();
      case TaskFilter.inProgress:
        return list.where((t) => t.status == TaskStatus.inProgress).toList();
      case TaskFilter.completed:
        return list.where((t) => t.status == TaskStatus.completed).toList();
    }
  });
});
