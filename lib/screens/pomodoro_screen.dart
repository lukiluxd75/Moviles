import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/timer_display.dart';
import '../services/notification_helper.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  //tiempos
  static const int tiempoEstudio = 1 * 60;
  static const int tiempoDescanso = 1 * 60;

  int _segundosRestantes = tiempoEstudio;
  Timer? _timer;
  bool _estaCorriendo = false;
  bool _esTiempoDeDescanso = false;

  void _alternarTimer() {
    setState(() {
      if (_estaCorriendo) {
        _timer?.cancel();
        _estaCorriendo = false;
        NotificationHelper.cancelarNotificacionTimer();
      } else {
        _estaCorriendo = true;
        NotificationHelper.mostrarTimerNotificacion(_segundosRestantes);

        _timer?.cancel();

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_segundosRestantes > 0) {
            setState(() {
              _segundosRestantes--;
            });
          } else {
            _finalizarCiclo();
          }
        });
      }
    });
  }

  void _finalizarCiclo() {
    _timer?.cancel();

    NotificationHelper.mostrarAlertaCiclo(
      _esTiempoDeDescanso ? "¡A estudiar!" : "¡Hora de descansar!",
    );

    setState(() {
      _estaCorriendo = false;
      _esTiempoDeDescanso = !_esTiempoDeDescanso;
      _segundosRestantes = _esTiempoDeDescanso ? tiempoDescanso : tiempoEstudio;
    });

    NotificationHelper.cancelarNotificacionTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          _esTiempoDeDescanso ? "¡Hora de descansar!" : "¡A darle con todo!",
        ),
      ),
    );
  }

  void _reiniciar() {
    _timer?.cancel();
    NotificationHelper.cancelarNotificacionTimer();

    setState(() {
      _estaCorriendo = false;
      _esTiempoDeDescanso = false;
      _segundosRestantes = tiempoEstudio;
    });
  }

  String _formatearTiempo() {
    int minutos = _segundosRestantes ~/ 60;
    int segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progreso =
        _segundosRestantes /
        (_esTiempoDeDescanso ? tiempoDescanso : tiempoEstudio);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _esTiempoDeDescanso ? "DESCANSO" : "CONCENTRACIÓN",
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                color: _esTiempoDeDescanso
                    ? Colors.greenAccent
                    : Colors.deepPurpleAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 40),
            TimerDisplay(
              progreso: progreso,
              tiempoFormateado: _formatearTiempo(),
              esDescanso: _esTiempoDeDescanso,
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 30),
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
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
