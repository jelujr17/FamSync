import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';

class NuevaTareaPage extends StatefulWidget {
  final Perfiles perfil;

  const NuevaTareaPage({super.key, required this.perfil});

  @override
  _NuevaTareaPageState createState() => _NuevaTareaPageState();
}

class _NuevaTareaPageState extends State<NuevaTareaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  int prioridad = 1;
  int categoria = 0;
  final List<int> _destinatarios = []; // IDs de los destinatarios seleccionados
  Map<String, Color> categoriasColores = {}; // Definir categoriasColores aquí
  String? categoriaSeleccionada;
  List<Categorias> categoriasDisponibles = [];
  Map<String, Color> colorNombreCategoria = {};
  List<String> nombresCategorias = [];
  List<Categorias> categorias = [];
  Color colorSeleccionado = Colores.principal;
  int? idCategoriaSeleccionada;
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void obtenerCategorias() async {
    categoriasDisponibles = await ServiciosCategorias()
        .getCategoriasByModulo(context, widget.perfil.UsuarioId, 1);

    // Llenar categoriasColores después de obtener las categorías
    for (var categoria in categoriasDisponibles) {
      categoriasColores[categoria.Nombre] =
          Color(int.parse("0xFF${categoria.Color}"));
    }

    obtenerNombresCategorias();

    setState(() {});
  }

  void obtenerNombresCategorias() {
    nombresCategorias = categoriasDisponibles.map((e) => e.Nombre).toList();
    print(nombresCategorias);
  }

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(
        nombresCategorias); // Asegúrate de que nombresTienda esté correctamente poblada

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  Future<void> cargarDatos() async {
    try {
      // Obtener categorías por módulo
      List<Categorias> categoriasObtenidas = await ServiciosCategorias()
          .getCategoriasByModulo(context, widget.perfil.UsuarioId, 5);

      setState(() {
        categorias = categoriasObtenidas;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea'),
        backgroundColor: Colores.principal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo de Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre';
                    }
                    return null;
                  },
                ),
                // Campo de Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una descripción';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  value: categoria == 0 && categorias.isNotEmpty
                      ? categorias.first.Id
                      : categoria, // Asegurarse de que siempre tenga un valor inicial válido.
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categorias.isEmpty
                      ? [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Cargando categorías...'),
                          )
                        ]
                      : categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria.Id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(
                                    int.parse('0xFF${categoria.Color}'),
                                  ),
                                  radius: 10,
                                ),
                                const SizedBox(width: 8),
                                Text(categoria.Nombre),
                              ],
                            ),
                          );
                        }).toList(),
                  onChanged: categorias.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            categoria = value!;
                            // Actualiza el color y otros detalles según la categoría seleccionada
                            colorSeleccionado = Color(
                              int.parse(
                                '0xFF${categorias.firstWhere((c) => c.Id == categoria).Color}',
                              ),
                            );
                          });
                        },
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Por favor, selecciona una categoría válida.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Crear la tarea
                      final nuevaTarea = {
                        'Id': null, // Será asignado por el backend
                        'Creador': widget.perfil.Id, // ID del creador
                        'Destinatario': _destinatarios,
                        'Nombre': _nombreController.text,
                        'Descripcion': _descripcionController.text,
                        'Categoria': categoria,
                        'IdEvento': null, // Opcional inicialmente
                        'Prioridad': prioridad,
                        'Progreso': 0,
                      };

                      // Aquí puedes enviar la tarea al backend o procesarla
                      print('Tarea creada: $nuevaTarea');

                      // Regresar a la pantalla anterior
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
