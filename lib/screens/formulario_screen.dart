import 'package:flutter/material.dart';
import '../models/tarea_model.dart';
import '../services/database_helper.dart';
import '../widgets/burbuja_container.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();

  String _materiaSeleccionada = "";
  List<String> _materiasSugeridas = [];

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    final materias = await DatabaseHelper.instance.getMaterias();
    setState(() {
      _materiasSugeridas = materias;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Nueva Tarea", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 113, 220, 208),
              Color.fromARGB(255, 92, 61, 153),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: BurbujaContainer(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      "¿Qué tienes pendiente?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // INPUT DE TÍTULO
                    TextFormField(
                      controller: _tituloController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Título de la tarea",
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: "Ej. Estudiar para el parcial",
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.task_alt,
                          color: Colors.white70,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // INPUT DE MATERIA (AUTOCOMPLETE AERO)
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _materiasSugeridas;
                        }
                        return _materiasSugeridas.where((String option) {
                          return option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                        });
                      },
                      onSelected: (String selection) {
                        _materiaSeleccionada = selection;
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Materia (Selecciona o escribe)",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.book,
                                  color: Colors.white70,
                                ),
                                suffixIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                              ),
                              onChanged: (value) =>
                                  _materiaSeleccionada = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La materia es obligatoria';
                                }
                                return null;
                              },
                            );
                          },
                    ),

                    const SizedBox(height: 40),

                    // BOTÓN GUARDAR
                    ElevatedButton(
                      onPressed: _guardarTarea,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Guardar Tarea",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarTarea() async {
    if (_formKey.currentState!.validate()) {
      final nuevaTarea = Tarea(
        titulo: _tituloController.text,
        materia: _materiaSeleccionada,
        estado: 0,
      );

      await DatabaseHelper.instance.crearTarea(nuevaTarea);

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea guardada correctamente')),
      );
    }
  }
}
