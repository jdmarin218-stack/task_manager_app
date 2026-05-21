# Task Manager App 📋

Aplicación de gestión de tareas desarrollada con Flutter como proyecto de la asignatura de desarrollo móvil avanzado.

## 🚀 Tecnologías utilizadas

- **Flutter** — Framework principal
- **Riverpod** — Manejo de estado
- **Go Router** — Navegación y rutas
- **Clean Architecture** — Estructura del proyecto
- **SharedPreferences** — Persistencia local
- **Flutter Local Notifications** — Notificaciones locales
- **Permission Handler** — Permisos en tiempo de ejecución

## 📁 Estructura del proyecto

## ✨ Funcionalidades

- Crear, editar y eliminar tareas
- Prioridades: Baja, Media, Alta
- Estados: Pendiente, En progreso, Completada
- Filtros por estado en tiempo real
- Fecha límite con indicador visual
- Drawer lateral con estadísticas
- Notificaciones locales al crear tareas
- Persistencia local con SharedPreferences
- Animaciones en splash screen

## 📱 Cómo ejecutar

### Requisitos
- Flutter SDK 3.x
- Android Studio con emulador Android API 33+
- Git

### Pasos

1. Clona el repositorio:
```bash
git clone https://github.com/jdmarin218-stack/task_manager_app.git
cd task_manager_app
```

2. Instala dependencias:
```bash
flutter pub get
```

3. Ejecuta la app:
```bash
# En Android (emulador o dispositivo físico)
flutter run -d emulator-5554

# En Chrome
flutter run -d chrome

# En Linux Desktop
flutter run -d linux
```

## 👨‍💻 Autor

**Julián Marín** — [@jdmarin218-stack](https://github.com/jdmarin218-stack)

ITM — Tecnología en Desarrollo de Software
