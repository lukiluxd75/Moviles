import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _notificaciones
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificaciones.initialize(initSettings);
  }

  static Future<void> mostrarTimerNotificacion(int segundosRestantes) async {
    final int targetTime =
        DateTime.now().millisecondsSinceEpoch + (segundosRestantes * 1000);

    final androidDetails = AndroidNotificationDetails(
      'canal_pomodoro_timer',
      'Temporizador Pomodoro',
      channelDescription:
          'Muestra el cronómetro activo en la barra de notificaciones',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: true,
      when: targetTime,
      usesChronometer: true,
      chronometerCountDown: true,
      onlyAlertOnce: true,
    );

    final details = NotificationDetails(android: androidDetails);
    await _notificaciones.show(
      10,
      'Pomodoro en curso',
      'Concéntrate...',
      details,
    );
  }

  static Future<void> cancelarNotificacionTimer() async {
    await _notificaciones.cancel(10);
  }

  // Alerta de fin de ciclo con vibración
  static Future<void> mostrarAlertaCiclo(String mensaje) async {
    const androidDetails = AndroidNotificationDetails(
      'canal_alertas',
      'Alertas de Estudio',
      channelDescription: 'Avisos de fin de ciclo de estudio o descanso',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);
    await _notificaciones.show(
      11, 
      '¡Ciclo Finalizado!',
      mensaje,
      details,
    );
  }

  // Para futuras notis de tareas y así
  static Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'canal_estudio',
      'Avisos Generales',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificaciones.show(id, titulo, cuerpo, details);
  }
}