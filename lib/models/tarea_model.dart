class Tarea {
  final int? id;
  final String titulo;
  final String materia;
  final int estado;
  Tarea({
    this.id,
    required this.titulo,
    required this.materia,
    this.estado = 0,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'titulo': titulo, 'materia': materia, 'estado': estado};
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      materia: map['materia'],
      estado: map['estado'],
    );
  }
}
