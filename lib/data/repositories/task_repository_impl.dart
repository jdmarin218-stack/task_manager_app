import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';

/// Implementación concreta del repositorio de tareas
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<TaskModel>> getAllTasks() => _datasource.getTasks();

  @override
  Future<void> saveTask(TaskModel task) async {
    final tasks = await _datasource.getTasks();
    tasks.add(task);
    await _datasource.saveTasks(tasks);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final tasks = await _datasource.getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _datasource.saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await _datasource.getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _datasource.saveTasks(tasks);
  }
}
