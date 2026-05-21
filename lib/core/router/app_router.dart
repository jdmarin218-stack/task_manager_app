import 'package:go_router/go_router.dart';
import '../../domain/models/task_model.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/task_detail/task_detail_screen.dart';

/// Rutas nombradas de la aplicación
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String taskDetail = '/task-detail';
  static const String newTask = '/new-task';
}

/// Configuración de Go Router
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    /// Pantalla de splash inicial
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    /// Pantalla principal con lista de tareas
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    /// Pantalla de detalle / edición de tarea existente
    GoRoute(
      path: AppRoutes.taskDetail,
      builder: (context, state) {
        final task = state.extra as TaskModel?;
        return TaskDetailScreen(task: task);
      },
    ),

    /// Pantalla de creación de nueva tarea
    GoRoute(
      path: AppRoutes.newTask,
      builder: (context, state) => const TaskDetailScreen(task: null),
    ),
  ],
);
