import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarea_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('estudio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materias (
        nombre TEXT PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE tareas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        materia TEXT NOT NULL,
        estado INTEGER NOT NULL,
        FOREIGN KEY (materia) REFERENCES materias (nombre)
      )
    ''');
  }

  Future<void> insertarMateria(String nombre) async {
    final db = await instance.database;
    await db.insert('materias', {
      'nombre': nombre,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> getMaterias() async {
    final db = await instance.database;
    final result = await db.query('materias');
    return result.map((json) => json['nombre'] as String).toList();
  }

  Future<int> crearTarea(Tarea tarea) async {
    final db = await instance.database;
    await insertarMateria(tarea.materia);
    return await db.insert('tareas', tarea.toMap());
  }

  Future<List<Tarea>> getTareas() async {
    final db = await instance.database;
    final result = await db.query('tareas', orderBy: 'id DESC');
    return result.map((json) => Tarea.fromMap(json)).toList();
  }

  Future<int> actualizarEstado(int id, int estado) async {
    final db = await instance.database;
    return await db.update(
      'tareas',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
