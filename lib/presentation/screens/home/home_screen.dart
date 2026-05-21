import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';

/// Pantalla principal con lista de tareas y filtros
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final allTasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Contador de tareas completadas
          allTasks.whenOrNull(
                data: (tasks) {
                  final completed = tasks
                      .where((t) => t.status == TaskStatus.completed)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '$completed/${tasks.length}',
                        style: const TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ) ??
              const SizedBox(),
        ],
      ),
      // Drawer lateral
      drawer: _AppDrawer(),
      body: Column(
        children: [
          // Barra de filtros
          _FilterBar(currentFilter: currentFilter),
          // Lista de tareas
          Expanded(
            child: filteredTasks.when(
              data: (tasks) => tasks.isEmpty
                  ? _EmptyState(filter: currentFilter)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => context.push(
                            AppRoutes.taskDetail,
                            extra: task,
                          ),
                        );
                      },
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ),
          ),
        ],
      ),
      // Botón para crear nueva tarea
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newTask),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

/// Barra de filtros horizontales
class _FilterBar extends ConsumerWidget {
  final TaskFilter currentFilter;
  const _FilterBar({required this.currentFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      color: AppTheme.surfaceColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: TaskFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return GestureDetector(
            onTap: () =>
                ref.read(taskFilterProvider.notifier).setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.white24,
                ),
              ),
              child: Center(
                child: Text(
                  _filterLabel(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Todas';
      case TaskFilter.pending:
        return 'Pendientes';
      case TaskFilter.inProgress:
        return 'En progreso';
      case TaskFilter.completed:
        return 'Completadas';
    }
  }
}

/// Estado vacío cuando no hay tareas
class _EmptyState extends StatelessWidget {
  final TaskFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            filter == TaskFilter.all
                ? 'No hay tareas aún'
                : 'No hay tareas en esta categoría',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para crear una nueva tarea',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer lateral con navegación y estadísticas
class _AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);

    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Task Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Organiza tu día con estilo',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Estadísticas
          tasksAsync.whenOrNull(
                data: (tasks) {
                  final pending = tasks
                      .where((t) => t.status == TaskStatus.pending)
                      .length;
                  final inProgress = tasks
                      .where((t) => t.status == TaskStatus.inProgress)
                      .length;
                  final completed = tasks
                      .where((t) => t.status == TaskStatus.completed)
                      .length;
                  return Column(
                    children: [
                      _StatTile(
                        icon: Icons.radio_button_unchecked,
                        label: 'Pendientes',
                        count: pending,
                        color: AppTheme.statusPending,
                      ),
                      _StatTile(
                        icon: Icons.timelapse,
                        label: 'En progreso',
                        count: inProgress,
                        color: AppTheme.statusInProgress,
                      ),
                      _StatTile(
                        icon: Icons.check_circle,
                        label: 'Completadas',
                        count: completed,
                        color: AppTheme.statusCompleted,
                      ),
                      const Divider(color: Colors.white12),
                    ],
                  );
                },
              ) ??
              const SizedBox(),
          // Opciones de navegación
          ListTile(
            leading: const Icon(Icons.home, color: AppTheme.primaryColor),
            title: const Text(
              'Inicio',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_task, color: AppTheme.secondaryColor),
            title: const Text(
              'Nueva tarea',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.newTask);
            },
          ),
        ],
      ),
    );
  }
}

/// Tile de estadística en el drawer
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
