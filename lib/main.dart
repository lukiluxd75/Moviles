import 'package:flutter/material.dart';
import 'services/notification_helper.dart';
import 'screens/formulario_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'widgets/burbuja_container.dart';
import '../models/tarea_model.dart';
import '../services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  runApp(const EstudiaApp());
}

class EstudiaApp extends StatelessWidget {
  const EstudiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EstudiApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8E2DE2),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceActual = 0;

  final List<Widget> _paginas = [const DashboardPage(), const PomodoroScreen()];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 113, 220, 208), // Morado intenso
            Color.fromARGB(255, 92, 61, 153), // Azul oscuro
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _paginas[_indiceActual],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white.withOpacity(0.1),
          indicatorColor: Colors.white.withOpacity(0.3),
          selectedIndex: _indiceActual,
          onDestinationSelected: (int index) {
            setState(() {
              _indiceActual = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home, color: Colors.white),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.timer, color: Colors.white),
              label: 'Pomodoro',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Tarea> _tareas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    final tareasGuardadas = await DatabaseHelper.instance.getTareas();
    setState(() {
      _tareas = tareasGuardadas;
      _cargando = false;
    });
  }

  Future<void> _cambiarEstadoTarea(Tarea tarea, bool? completada) async {
    final nuevoEstado = completada == true ? 1 : 0;
    await DatabaseHelper.instance.actualizarEstado(tarea.id!, nuevoEstado);
    _cargarTareas();
  }

  @override
  Widget build(BuildContext context) {
    final completadas = _tareas.where((t) => t.estado == 1).length;
    final total = _tareas.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Gestor de Estudio",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BurbujaContainer(
                padding: 20.0,
                child: Column(
                  children: [
                    const Text(
                      "Tu progreso de hoy",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$completadas / $total Tareas",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Pendientes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _tareas.isEmpty
                    ? const Center(
                        child: Text(
                          "No tienes tareas. ¡Toca el '+' para empezar!",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = _tareas[index];
                          final estaCompletada = tarea.estado == 1;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: BurbujaContainer(
                              padding: 5.0,
                              child: CheckboxListTile(
                                activeColor: Colors.deepPurpleAccent,
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                title: Text(
                                  tarea.titulo,
                                  style: TextStyle(
                                    color: estaCompletada
                                        ? Colors.white54
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: estaCompletada
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  tarea.materia,
                                  style: TextStyle(
                                    color: estaCompletada
                                        ? Colors.white38
                                        : Colors.white70,
                                  ),
                                ),
                                value: estaCompletada,
                                onChanged: (bool? valor) =>
                                    _cambiarEstadoTarea(tarea, valor),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        onPressed: () async {
          // 3. NAVEGACIÓN INTELIGENTE: Esperamos a que vuelva del formulario
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioScreen()),
          );

          // Si el formulario devolvió 'true' (se guardó algo), recargamos la lista
          if (resultado == true) {
            _cargarTareas();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
