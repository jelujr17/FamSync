import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Categoria_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Descripcion_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Fechas_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Nombre_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Crear/Crear_Perfiles_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/calendario.dart';
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
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final TextEditingController _prioridadController = TextEditingController();

  final List<int> _perfilSeleccionado = [];
  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  List<String> nombresCategoria = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  int prioridad = 0;
  bool mostrarErrorPerfiles = false;
  DateTime fechaEvento = DateTime.now();
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  bool todoElDia = false;

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
        Provider.of<CategoriasProvider>(context, listen: true);
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
      int? categoriaId;
      if (categoria != "Sin categoría") {
        categoriaId = categoriasDisponibles
            .firstWhere(
              (element) => element.Nombre == categoriaSeleccionada,
              orElse: () => Categorias(
                  Id: 0,
                  Nombre: "Sin Categoría",
                  IdModulo: 0,
                  Color: '000000',
                  IdUsuario: 0),
            )
            .Id;
      }

      print("Categoría seleccionada: $categoriaId");
      if (categoriaId == 0) {
        categoriaId = null;
      }
      DateTime fechaInicio = fechaEvento;
      DateTime fechaFin = fechaEvento;
      if (todoElDia) {
        horaInicio = const TimeOfDay(hour: 0, minute: 0);
        horaFin = const TimeOfDay(hour: 23, minute: 59);
       
      }
      fechaInicio = DateTime(
          fechaEvento.year,
          fechaEvento.month,
          fechaEvento.day,
          horaInicio!.hour,
          horaInicio!.minute,
        );
        fechaFin = DateTime(
          fechaEvento.year,
          fechaEvento.month,
          fechaEvento.day,
          horaFin!.hour,
          horaFin!.minute,
        );

      final nuevoEvento = Eventos(
        Id: 0,
        Nombre: nombre,
        Descripcion: descripcion,
        FechaInicio: fechaInicio.toString(),
        FechaFin: fechaFin.toString(),
        IdUsuarioCreador: widget.perfil.UsuarioId,
        IdPerfilCreador: widget.perfil.Id,
        IdCategoria: categoriaId,
        Participantes: _perfilSeleccionado,
        IdTarea: null,
      );

      final exito = await ServicioEventos().registrarEvento(
        context,
        nuevoEvento.Nombre,
        nuevoEvento.Descripcion,
        nuevoEvento.FechaInicio,
        nuevoEvento.FechaFin,
        nuevoEvento.IdUsuarioCreador,
        nuevoEvento.IdPerfilCreador,
        nuevoEvento.IdCategoria,
        nuevoEvento.Participantes,
      );

      if (exito) {
        print("Tarea creada con éxito");
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Calendario(perfil: widget.perfil),
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
        print("Error al crear el evento");
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
                  prioridadController: _prioridadController,
                  onGuardar: _crearEvento,
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
                  fechaEvento: fechaEvento,
                  horaInicio: horaInicio,
                  horaFin: horaFin,
                  todoElDia: todoElDia,
                  onFechaChanged: (nuevaFecha) {
                    setState(() {
                      fechaEvento = nuevaFecha!;
                    });
                  },
                  onHoraInicioChanged: (nuevaHora) {
                    setState(() {
                      horaInicio = nuevaHora;
                    });
                  },
                  onHoraFinChanged: (nuevaHora) {
                    setState(() {
                      horaFin = nuevaHora;
                    });
                  },
                  onTodoElDiaChanged: (valor) {
                    setState(() {
                      todoElDia = valor;
                      if (valor) {
                        horaInicio = const TimeOfDay(hour: 0, minute: 0);
                        horaFin = const TimeOfDay(hour: 23, minute: 59);
                      }
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
                onPressed: _crearEvento,
                child: Text("Registrar Evento",
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
  final Function(int) onPrioridadSeleccionada;
  final DateTime? fechaEvento;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFin;
  final bool todoElDia;
  final void Function(DateTime?) onFechaChanged;
  final void Function(TimeOfDay?) onHoraInicioChanged;
  final void Function(TimeOfDay?) onHoraFinChanged;
  final void Function(bool) onTodoElDiaChanged;

  int prioridadSeleccionada;
  final TextEditingController prioridadController;

  FormularioCrearEvento({
    super.key,
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
    required this.prioridadController,
    required this.fechaEvento,
    required this.horaInicio,
    required this.horaFin,
    required this.todoElDia,
    required this.onFechaChanged,
    required this.onHoraInicioChanged,
    required this.onHoraFinChanged,
    required this.onTodoElDiaChanged,
  });

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
              CampoCategoriaCrearEvento(
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
                  : CampoPerfilesCrearEvento(
                      perfiles: perfiles,
                      perfilSeleccionado: widget.perfilSeleccionado,
                      onPerfilSeleccionado: (perfilId) {
                        setState(() {
                          if (widget.perfilSeleccionado.contains(perfilId)) {
                            widget.perfilSeleccionado.remove(perfilId);
                          } else {
                            widget.perfilSeleccionado.add(perfilId);
                          }
                        });
                      },
                    ),
              const SizedBox(height: 20),
              CampoFechasCrearEvento(
                fecha: widget.fechaEvento,
                horaInicio: widget.horaInicio,
                horaFin: widget.horaFin,
                todoElDia: widget.todoElDia,
                onFechaChanged: widget.onFechaChanged,
                onHoraInicioChanged: widget.onHoraInicioChanged,
                onHoraFinChanged: widget.onHoraFinChanged,
                onTodoElDiaChanged: widget.onTodoElDiaChanged,
                validatorFecha: (fecha) {
                  if (fecha == null) return 'Selecciona la fecha';
                  return null;
                },
                validatorHoraInicio: (hora) {
                  if (!widget.todoElDia && hora == null)
                    return 'Selecciona la hora de inicio';
                  return null;
                },
                validatorHoraFin: (hora) {
                  if (!widget.todoElDia && hora == null)
                    return 'Selecciona la hora de fin';
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

class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}
