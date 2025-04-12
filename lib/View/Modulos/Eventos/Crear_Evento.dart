import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Descripcion_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Nombre_Evento.dart';
import 'package:famsync/View/Modulos/Tareas/agenda.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
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

class CrearEvento extends StatefulWidget {
  final Perfiles perfil;
  const CrearEvento({super.key, required this.perfil});

  @override
  CrearEventoState createState() => CrearEventoState();
}

class CrearEventoState extends State<CrearEvento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final List<int> _perfilSeleccionado = [];
  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  bool mostrarErrorPerfiles = false;
  List<String> nombresCategoria = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(context, widget.perfil.UsuarioId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    obtenerCategorias();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void obtenerCategorias() {
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasDisponibles = categoriasProvider.categorias;
    nombresCategoria = categoriasProvider.categorias
        .map((e) => e.Nombre)
        .toList(); // Obtener nombres de las categorías
    print("Nombres de categorías: $nombresCategoria");
  }

  Future<void> _crearEvento() async {
    if (_perfilSeleccionado.isEmpty) {
      setState(() {
        mostrarErrorPerfiles = true;
      });
      return;
    } else {
      setState(() {
        mostrarErrorPerfiles = false;
      });
    }

    if (_formKey.currentState!.validate()) {
      if (_fechaInicio == null ||
          _horaInicio == null ||
          _fechaFin == null ||
          _horaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecciona las fechas y horas.')),
        );
        return;
      }

      final nombre = _nombreController.text;
      final descripcion = _descripcionController.text;
      final categoria = categoriaSeleccionada ?? "Sin categoría";
      int? categoriaId = categoriasDisponibles
          .firstWhere(
            (element) => element.Nombre == categoria,
            orElse: () => Categorias(
              Id: 0,
              Nombre: "Sin Categoría",
              IdModulo: 0,
              Color: '000000',
              IdUsuario: 0,
            ),
          )
          .Id;

      if (categoriaId == 0) categoriaId = null;

      final nuevaTarea = Tareas(
        Id: 0,
        Nombre: nombre,
        Descripcion: descripcion,
        Creador: widget.perfil.Id,
        Destinatario: _perfilSeleccionado,
        Categoria: categoriaId,
        IdEvento: null,
        Prioridad: 0,
        Progreso: 0,
      );

      final exito = await ServicioTareas().registrarTarea(
        context,
        nuevaTarea.Creador,
        nuevaTarea.Destinatario,
        nuevaTarea.Nombre,
        nuevaTarea.Descripcion,
        nuevaTarea.IdEvento,
        nuevaTarea.Categoria,
        nuevaTarea.Prioridad,
        nuevaTarea.Progreso,
      );

      if (exito) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                Agenda(perfil: widget.perfil),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el evento.')),
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
                    "Crear Evento",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colores.texto, fontWeight: FontWeight.bold),
                  ),
                ),
                FormularioCrearEvento(
                  perfil: widget.perfil,
                  formKey: _formKey,
                  nombreController: _nombreController,
                  descripcionController: _descripcionController,
                  dropdownSearchFieldController: _dropdownSearchFieldController,
                  perfilSeleccionado: _perfilSeleccionado,
                  categoriasDisponibles: categoriasDisponibles,
                  categoriaSeleccionada: categoriaSeleccionada,
                  nombresCategoria: nombresCategoria,
                  onGuardar: _crearEvento,
                  onCategoriaSeleccionada: (String? tienda) {
                    setState(() {
                      categoriaSeleccionada = tienda;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FormularioCrearEvento extends StatefulWidget {
  final Perfiles perfil;
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final TextEditingController dropdownSearchFieldController;
  final List<int> perfilSeleccionado;
  final List<Categorias> categoriasDisponibles;
  String? categoriaSeleccionada;
  final List<String> nombresCategoria;
  final Function() onGuardar;
  final Function(String?) onCategoriaSeleccionada;

  FormularioCrearEvento(
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
      required this.onCategoriaSeleccionada});

  @override
  FormularioCrearEventoState createState() => FormularioCrearEventoState();
}

class FormularioCrearEventoState extends State<FormularioCrearEvento> {
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
              CampoNombreCrearEvento(
                nombreController: widget.nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CampoDescripcionCrearEvento(
                descripcionController: widget.descripcionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre válido.';
                  }
                  return null;
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
