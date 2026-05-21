import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

/// Tarjeta visual que representa una tarea en la lista
class TaskCard extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: _priorityColor(task.priority),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Título de la tarea
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                // Badge de prioridad
                _PriorityBadge(priority: task.priority),
                const SizedBox(width: 8),
                // Menú de opciones
                _TaskMenu(task: task),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                // Badge de estado
                _StatusBadge(status: task.status),
                const Spacer(),
                // Fecha límite si existe
                if (task.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: _dueDateColor(task.dueDate!),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _dueDateColor(task.dueDate!),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.priorityLow;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
    }
  }

  Color _dueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return AppTheme.priorityHigh;
    if (dueDate.difference(now).inDays <= 2) return AppTheme.priorityMedium;
    return Colors.white54;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Badge de prioridad
class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color(), width: 1),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: 11,
          color: _color(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _color() {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.priorityLow;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
    }
  }

  String _label() {
    switch (priority) {
      case TaskPriority.low:
        return 'Baja';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.high:
        return 'Alta';
    }
  }
}

/// Badge de estado
class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 12, color: _color()),
          const SizedBox(width: 4),
          Text(
            _label(),
            style: TextStyle(
              fontSize: 11,
              color: _color(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _color() {
    switch (status) {
      case TaskStatus.pending:
        return AppTheme.statusPending;
      case TaskStatus.inProgress:
        return AppTheme.statusInProgress;
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
    }
  }

  IconData _icon() {
    switch (status) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

  String _label() {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En progreso';
      case TaskStatus.completed:
        return 'Completada';
    }
  }
}

/// Menú contextual de opciones de la tarea
class _TaskMenu extends ConsumerWidget {
  final TaskModel task;
  const _TaskMenu({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
      color: AppTheme.surfaceColor,
      onSelected: (value) async {
        final notifier = ref.read(taskProvider.notifier);
        switch (value) {
          case 'pending':
            await notifier.updateStatus(task.id, TaskStatus.pending);
            break;
          case 'inProgress':
            await notifier.updateStatus(task.id, TaskStatus.inProgress);
            break;
          case 'completed':
            await notifier.updateStatus(task.id, TaskStatus.completed);
            break;
          case 'delete':
            await notifier.deleteTask(task.id);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pending',
          child: Row(children: [
            Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 18),
            SizedBox(width: 8),
            Text('Pendiente', style: TextStyle(color: Colors.white)),
          ]),
        ),
        const PopupMenuItem(
          value: 'inProgress',
          child: Row(children: [
            Icon(Icons.timelapse, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Text('En progreso', style: TextStyle(color: Colors.white)),
          ]),
        ),
        const PopupMenuItem(
          value: 'completed',
          child: Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Text('Completada', style: TextStyle(color: Colors.white)),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Text('Eliminar', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }
}
