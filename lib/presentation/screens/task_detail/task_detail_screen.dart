import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/task_model.dart';
import '../../providers/task_provider.dart';

/// Pantalla para crear o editar una tarea
class TaskDetailScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  DateTime? _selectedDueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Si viene una tarea existente, cargar sus datos
    _isEditing = widget.task != null;
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
      _selectedDueDate = widget.task!.dueDate;
    } else {
      _selectedPriority = TaskPriority.medium;
      _selectedStatus = TaskStatus.pending;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Guardar o actualizar la tarea
  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es obligatorio'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final notifier = ref.read(taskProvider.notifier);

    if (_isEditing) {
      // Actualizar tarea existente
      await notifier.updateTask(
        widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: _selectedStatus,
          dueDate: _selectedDueDate,
        ),
      );
    } else {
      // Crear nueva tarea
      await notifier.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
    }

    if (mounted) context.pop();
  }

  /// Seleccionar fecha límite
  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: AppTheme.surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar tarea' : 'Nueva tarea',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Botón guardar en AppBar
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo título
            _SectionLabel(label: 'Título'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Escribe el título de la tarea...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              maxLength: 80,
            ),
            const SizedBox(height: 20),

            // Campo descripción
            _SectionLabel(label: 'Descripción'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Agrega detalles opcionales...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              maxLines: 4,
              maxLength: 300,
            ),
            const SizedBox(height: 20),

            // Selector de prioridad
            _SectionLabel(label: 'Prioridad'),
            const SizedBox(height: 8),
            _PrioritySelector(
              selected: _selectedPriority,
              onChanged: (p) => setState(() => _selectedPriority = p),
            ),
            const SizedBox(height: 20),

            // Selector de estado (solo en edición)
            if (_isEditing) ...[
              _SectionLabel(label: 'Estado'),
              const SizedBox(height: 8),
              _StatusSelector(
                selected: _selectedStatus,
                onChanged: (s) => setState(() => _selectedStatus = s),
              ),
              const SizedBox(height: 20),
            ],

            // Selector de fecha límite
            _SectionLabel(label: 'Fecha límite'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'Seleccionar fecha (opcional)',
                      style: TextStyle(
                        color: _selectedDueDate != null
                            ? Colors.white
                            : Colors.white38,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDueDate = null),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white38,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón guardar principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTask,
                icon: Icon(_isEditing ? Icons.save : Icons.add_task),
                label: Text(
                  _isEditing ? 'Actualizar tarea' : 'Crear tarea',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta de sección
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Selector de prioridad
class _PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selected;
        final color = _color(priority);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.3) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(_icon(priority), color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    _label(priority),
                    style: TextStyle(
                      color: isSelected ? color : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return AppTheme.priorityLow;
      case TaskPriority.medium: return AppTheme.priorityMedium;
      case TaskPriority.high: return AppTheme.priorityHigh;
    }
  }

  IconData _icon(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return Icons.arrow_downward;
      case TaskPriority.medium: return Icons.remove;
      case TaskPriority.high: return Icons.arrow_upward;
    }
  }

  String _label(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return 'Baja';
      case TaskPriority.medium: return 'Media';
      case TaskPriority.high: return 'Alta';
    }
  }
}

/// Selector de estado
class _StatusSelector extends StatelessWidget {
  final TaskStatus selected;
  final ValueChanged<TaskStatus> onChanged;

  const _StatusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((status) {
        final isSelected = status == selected;
        final color = _color(status);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.3) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(_icon(status), color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    _label(status),
                    style: TextStyle(
                      color: isSelected ? color : Colors.white54,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(TaskStatus s) {
    switch (s) {
      case TaskStatus.pending: return AppTheme.statusPending;
      case TaskStatus.inProgress: return AppTheme.statusInProgress;
      case TaskStatus.completed: return AppTheme.statusCompleted;
    }
  }

  IconData _icon(TaskStatus s) {
    switch (s) {
      case TaskStatus.pending: return Icons.radio_button_unchecked;
      case TaskStatus.inProgress: return Icons.timelapse;
      case TaskStatus.completed: return Icons.check_circle;
    }
  }

  String _label(TaskStatus s) {
    switch (s) {
      case TaskStatus.pending: return 'Pendiente';
      case TaskStatus.inProgress: return 'En progreso';
      case TaskStatus.completed: return 'Completada';
    }
  }
}
