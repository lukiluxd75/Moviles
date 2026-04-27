import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/timer_display.dart';
import '../widgets/burbuja_container.dart';
import '../services/notification_helper.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Tiempos reales (en segundos)
  static const int estudioPred = 25 * 60;
  static const int descansoCorto = 5 * 60;
  static const int descansoLargo = 15 * 60;

  // Estado actual
  int _segundosRestantes = estudioPred;
  Timer? _timer;
  bool _estaCorriendo = false;
  bool _esTiempoDeDescanso = false;

  // Control de precisión en segundo plano
  DateTime? _inicioCiclo;
  int _duracionTotal = estudioPred;

  // Contador de pomodoros completados
  int _pomodorosCompletados = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Obtener la duración que corresponde según el tipo de ciclo actual
  int _duracionActual() {
    if (!_esTiempoDeDescanso) return estudioPred;
    // Después de cada 4 pomodoros, descanso largo
    return (_pomodorosCompletados % 4 == 0) ? descansoLargo : descansoCorto;
  }

  // Iniciar o pausar el temporizador
  void _alternarTimer() {
    HapticFeedback.lightImpact(); // Feedback táctil
    setState(() {
      if (_estaCorriendo) {
        _pausarTimer();
      } else {
        _iniciarTimer();
      }
    });
  }

  void _iniciarTimer() {
    _estaCorriendo = true;
    _duracionTotal = _duracionActual();
    _inicioCiclo = DateTime.now();

    NotificationHelper.mostrarTimerNotificacion(_segundosRestantes);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final transcurrido =
          DateTime.now().difference(_inicioCiclo!).inSeconds;
      final restante = _duracionTotal - transcurrido;

      if (restante <= 0) {
        _finalizarCiclo();
      } else {
        setState(() {
          _segundosRestantes = restante;
        });
      }
    });
  }

  void _pausarTimer() {
    _timer?.cancel();
    _estaCorriendo = false;
    NotificationHelper.cancelarNotificacionTimer();
  }

  void _finalizarCiclo() {
    _timer?.cancel();
    _estaCorriendo = false;

    // Si era ciclo de estudio -> ahora descanso, y viceversa
    if (_esTiempoDeDescanso) {
      // Terminó un descanso, toca estudio
      setState(() {
        _esTiempoDeDescanso = false;
        _segundosRestantes = estudioPred;
      });
      NotificationHelper.mostrarAlertaCiclo("¡A darle con todo!");
      mostrarSnackBar("¡A darle con todo!");
    } else {
      // Terminó un pomodoro de estudio
      _pomodorosCompletados++;
      setState(() {
        _esTiempoDeDescanso = true;
        _segundosRestantes = _duracionActual(); // corto o largo
      });
      NotificationHelper.mostrarAlertaCiclo(
        _pomodorosCompletados % 4 == 0
            ? "¡Descanso largo merecido!"
            : "¡Hora de descansar!",
      );
      mostrarSnackBar(
        _pomodorosCompletados % 4 == 0
            ? "¡Descanso largo merecido!"
            : "¡Hora de descansar!",
      );
    }

    NotificationHelper.cancelarNotificacionTimer();
  }

  void mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        content: Text(mensaje),
      ),
    );
  }

  // Reiniciar toda la sesión
  void _reiniciar() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    NotificationHelper.cancelarNotificacionTimer();
    setState(() {
      _estaCorriendo = false;
      _esTiempoDeDescanso = false;
      _segundosRestantes = estudioPred;
      _pomodorosCompletados = 0;
    });
  }

  // Saltar al final del ciclo actual (útil si terminaste antes)
  void _saltarCiclo() {
    HapticFeedback.selectionClick();
    if (_segundosRestantes > 0) {
      _finalizarCiclo();
    }
  }

  String _formatearTiempo() {
    int minutos = _segundosRestantes ~/ 60;
    int segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Proporción de tiempo restante (1 = completo, 0 = vacío)
    double progreso =
        _duracionTotal != 0 ? _segundosRestantes / _duracionTotal : 0.0;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: BurbujaContainer(
              padding: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título del estado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _esTiempoDeDescanso ? "DESCANSO" : "CONCENTRACIÓN",
                      key: ValueKey<String>(
                          _esTiempoDeDescanso ? "descanso" : "concentracion"),
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        color: _esTiempoDeDescanso
                            ? Colors.greenAccent
                            : Colors.deepPurpleAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Cronómetro circular
                  TimerDisplay(
                    progreso: progreso,
                    tiempoFormateado: _formatearTiempo(),
                    esDescanso: _esTiempoDeDescanso,
                  ),

                  const SizedBox(height: 20),

                  // Contador de pomodoros
                  Text(
                    '🍅 Pomodoros: $_pomodorosCompletados',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play / Pause
                      GestureDetector(
                        onTap: _alternarTimer,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _estaCorriendo
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.deepPurpleAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _estaCorriendo
                                  ? Colors.redAccent
                                  : Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _estaCorriendo ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Saltar ciclo
                      IconButton(
                        onPressed: (_segundosRestantes > 0) ? _saltarCiclo : null,
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white60,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Reiniciar
                      IconButton(
                        onPressed: _reiniciar,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white70,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}