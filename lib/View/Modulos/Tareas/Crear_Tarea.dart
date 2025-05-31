import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/View/Modulos/Tareas/Crear/Crear_Categoria_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Crear/Crear_Descripcion_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Crear/Crear_Nombre_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Crear/Crear_Perfiles_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Crear/Crear_Prioridad_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/agenda.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerfilProvider extends InheritedWidget {
  final Perfiles perfil;

  const PerfilProvider({
    super.key,
    required this.perfil,
    required super.child,
  });

  static PerfilProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PerfilProvider>();
  }

  @override
  bool updateShouldNotify(PerfilProvider oldWidget) {
    return perfil != oldWidget.perfil;
  }
}

class CrearTarea extends StatefulWidget {
  final Perfiles perfil;
  final String? categoria;
  const CrearTarea({super.key, required this.perfil, this.categoria});

  @override
  CrearTareaState createState() => CrearTareaState();
}

class CrearTareaState extends State<CrearTarea> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final TextEditingController _prioridadController = TextEditingController();

  final List<String> _perfilSeleccionado = [];
  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  List<String> nombresCategoria = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  int prioridad = 0;
  bool mostrarErrorPerfiles = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    categoriaSeleccionada = widget.categoria;
    print("Categoría seleccionada: $categoriaSeleccionada");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(user!.uid);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    obtenerCategorias(); // Mueve la lógica de categorías aquí
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _prioridadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void obtenerCategorias() {
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasDisponibles = categoriasProvider.categorias;
    nombresCategoria = categoriasProvider.categorias
        .map((e) => e.nombre)
        .toList(); // Obtener nombres de las categorías
    print("Nombres de categorías: $nombresCategoria");
  }

  Future<void> _crearTarea() async {
    if (_perfilSeleccionado.isEmpty) {
      setState(() {
        mostrarErrorPerfiles = true;
      });
      return; // Detener la ejecución si no hay perfiles seleccionados
    } else {
      setState(() {
        mostrarErrorPerfiles = false;
      });
    }

    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final descripcion = _descripcionController.text;
      final categoria = categoriaSeleccionada ?? "Sin categoría";
      String? categoriaId;
      if (categoria != "Sin categoría") {
        categoriaId = categoriasDisponibles
            .firstWhere(
              (element) => element.nombre == categoriaSeleccionada,
              orElse: () => Categorias(
                  CategoriaID: "",
                  Color: '000000',
                  nombre: "Sin Categoría",
                  PerfilID: widget.perfil.PerfilID),
            )
            .CategoriaID;
      }

      print("Categoría seleccionada: $categoriaId");
      if (categoriaId == 0) {
        categoriaId = null;
      }

      final nuevaTarea = Tareas(
        TareaID: "0",
        creador: widget.perfil.PerfilID,
        destinatario: _perfilSeleccionado,
        nombre: nombre,
        descripcion: descripcion,
        CategoriaID: categoriaId ?? "",
        EventoID:
            "", // Asigna el valor adecuado si tienes un evento, si no, deja vacío o null según tu modelo
        prioridad: prioridad,
        progreso: 0,
      );

      final exito = await ServicioTareas().registrarTarea(
        nuevaTarea.TareaID,
        nuevaTarea.creador,
        nuevaTarea.destinatario,
        nuevaTarea.nombre,
        nuevaTarea.descripcion,
        nuevaTarea.CategoriaID,
        nuevaTarea.EventoID,
        nuevaTarea.prioridad,
        nuevaTarea.progreso,
      );

      if (exito) {
        print("Tarea creada con éxito");
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Agenda(perfil: widget.perfil),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
      } else {
        print("Error al crear la tarea");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la tarea.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(100), // Aumenta la altura del AppBar
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false, // Desactiva el botón por defecto
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                  left: 0, top: 100), // Ajusta la posición
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context,
                            false); // No se realizó ninguna actualización
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colores.fondoAux,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colores.texto,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Crear Tarea",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colores.texto, fontWeight: FontWeight.bold),
                  ),
                ),
                FormularioCrearTarea(
                  perfil: widget.perfil,
                  formKey: _formKey,
                  nombreController: _nombreController,
                  descripcionController: _descripcionController,
                  dropdownSearchFieldController: _dropdownSearchFieldController,
                  perfilSeleccionado: _perfilSeleccionado,
                  categoriasDisponibles: categoriasDisponibles,
                  categoriaSeleccionada: categoriaSeleccionada,
                  nombresCategoria: nombresCategoria,
                  prioridadController: _prioridadController,
                  onGuardar: _crearTarea,
                  prioridadSeleccionada: prioridad,
                  onCategoriaSeleccionada: (String? tienda) {
                    setState(() {
                      categoriaSeleccionada = tienda;
                    });
                  },
                  onPrioridadSeleccionada: (int prioridad) {
                    setState(() {
                      this.prioridad = prioridad;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: TopRoundedContainer(
          color: Colores.fondo,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 12, bottom: 120),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colores.texto,
                  foregroundColor: Colores.fondo,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onPressed: _crearTarea,
                child: Text("Registrar Tarea",
                    style: TextStyle(color: Colores.fondoAux)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FormularioCrearTarea extends StatefulWidget {
  final Perfiles perfil;
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final TextEditingController dropdownSearchFieldController;
  final List<String> perfilSeleccionado;
  final List<Categorias> categoriasDisponibles;
  String? categoriaSeleccionada;
  final List<String> nombresCategoria;
  final Function() onGuardar;
  final Function(String?) onCategoriaSeleccionada;
  final Function(int) onPrioridadSeleccionada;

  int prioridadSeleccionada;
  final TextEditingController prioridadController;

  FormularioCrearTarea(
      {super.key,
      required this.perfil,
      required this.formKey,
      required this.nombreController,
      required this.descripcionController,
      required this.dropdownSearchFieldController,
      required this.perfilSeleccionado,
      required this.categoriasDisponibles,
      required this.categoriaSeleccionada,
      required this.nombresCategoria,
      required this.onGuardar,
      required this.onCategoriaSeleccionada,
      required this.prioridadSeleccionada,
      required this.onPrioridadSeleccionada,
      required this.prioridadController});

  @override
  FormularioCrearTareaState createState() => FormularioCrearTareaState();
}

class FormularioCrearTareaState extends State<FormularioCrearTarea> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PerfilesProvider>(
      builder: (context, perfilesProvider, child) {
        final perfiles = perfilesProvider.perfiles;

        return Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CampoNombreCrearTarea(
                nombreController: widget.nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CampoDescripcionCrearTarea(
                descripcionController: widget.descripcionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CampoCategoriaCrearTarea(
                categoriaSeleccionada: widget.categoriaSeleccionada,
                categoriasDisponibles: widget.nombresCategoria,
                categorias: widget.categoriasDisponibles,
                onCategoriaSeleccionada: (String? tienda) {
                  widget.onCategoriaSeleccionada(tienda);
                },
              ),
              const SizedBox(height: 20),
              perfiles.isEmpty
                  ? const Center(child: Text('No hay perfiles disponibles.'))
                  : CampoPerfilesCrearTarea(
                      perfiles: perfiles,
                      perfilSeleccionado: widget.perfilSeleccionado,
                      onPerfilSeleccionado: (PerfilID) {
                        setState(() {
                          if (widget.perfilSeleccionado.contains(PerfilID)) {
                            widget.perfilSeleccionado.remove(PerfilID);
                          } else {
                            widget.perfilSeleccionado.add(PerfilID);
                          }
                        });
                      },
                    ),
              const SizedBox(height: 20),
              CampoPrioridadCrearTarea(
                prioridadSeleccionada: widget.prioridadSeleccionada,
                onPrioridadSeleccionada: (value) {
                  widget.onPrioridadSeleccionada(value);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
