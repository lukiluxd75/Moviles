import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final double progreso;
  final String tiempoFormateado;
  final bool esDescanso;

  const TimerDisplay({
    super.key,
    required this.progreso,
    required this.tiempoFormateado,
    this.esDescanso = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: progreso,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade200,
            color: esDescanso ? Colors.green : Colors.deepPurple,
          ),
        ),
        Text(
          tiempoFormateado,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
