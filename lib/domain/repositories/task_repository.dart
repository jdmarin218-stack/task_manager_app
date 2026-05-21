import '../models/task_model.dart';

/// Contrato que define las operaciones disponibles sobre tareas
abstract class TaskRepository {
  /// Obtener todas las tareas guardadas
  Future<List<TaskModel>> getAllTasks();

  /// Guardar una tarea nueva
  Future<void> saveTask(TaskModel task);

  /// Actualizar una tarea existente
  Future<void> updateTask(TaskModel task);

  /// Eliminar una tarea por su ID
  Future<void> deleteTask(String id);
}
