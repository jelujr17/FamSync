import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Crear_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Barra_Busqueda_Tareas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Carta_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/agenda.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class TareasFiltradas extends StatefulWidget {
  final Perfiles perfil; // Identificador del perfil del usuario
  final String filtro;
  const TareasFiltradas(
      {super.key, required this.perfil, required this.filtro});

  @override
  State<TareasFiltradas> createState() => TareasFiltradasState();
}

class TareasFiltradasState extends State<TareasFiltradas> {
  List<Tareas> tareas = [];
  List<Tareas> tareasAux = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String aux = "";
  bool aux2 = false;

  @override
  void initState() {
    super.initState();
    _searchController
        .addListener(_filterTareas); // Escuchar cambios en la barra de búsqueda

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);
      tareasProvider.cargarTareas(
          context, widget.perfil.UsuarioId, widget.perfil.Id);

      setState(() {
        tareas = tareasProvider.tareas; // Actualiza la lista de tareas
        tareasAux =
            List.from(tareasProvider.tareas); // Copia de las tareas originales
        isLoading = false; // Indica que la carga ha terminado
      });
    });

    aux = widget.filtro;

    if (aux == "Todas") {
      aux = "Totales";
    }
  }

  void _filterTareas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filtrar tareas basándose en el texto ingresado
      tareas = tareasAux
          .where((tarea) => tarea.Nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void crearTarea(BuildContext context) async {
    if (aux2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CrearTarea(perfil: widget.perfil, categoria: widget.filtro),
        ),
      );

      if (result == true) {
        Navigator.pop(context, true); // Se realizó una actualización
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CrearTarea(perfil: widget.perfil, categoria: null),
        ),
      );

      if (result == true) {
        Navigator.pop(context, true); // Se realizó una actualización
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void cargarTareasCategoria() {
    final tareasProvider = Provider.of<TareasProvider>(context, listen: false);
    int idCategoria = 0;
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasProvider.cargarCategorias(context, widget.perfil.UsuarioId, 5);
    final categorias = categoriasProvider.categorias;

    try {
      tareas = tareasProvider.tareas;
      print("Tareas carfffftggyhgadas: ${tareas.length}");
      switch (widget.filtro) {
        case "Todas":
          tareas = tareas;
          break;
        case "Programadas":
          tareas = tareas.where((tarea) => tarea.IdEvento != null).toList();
          break;
        case "Por hacer":
          tareas = tareas.where((tarea) => tarea.Progreso == 0).toList();
          break;
        case "Completadas":
          tareas = tareas.where((tarea) => tarea.Progreso == 100).toList();
          break;
        case "Urgentes":
          tareas = tareas.where((tarea) => tarea.Prioridad == 3).toList();
          break;
        case "En proceso":
          tareas = tareas
              .where((tarea) => tarea.Progreso > 0 && tarea.Progreso < 100)
              .toList();
          break;
        default:
          print("Filtro no válido: ${widget.filtro}");
          aux2 = true;
          idCategoria = categorias
              .firstWhere(
                (categoria) => categoria.Nombre == widget.filtro,
              )
              .Id;
          print("ID Categoria: $idCategoria");
          tareas =
              tareas.where((tarea) => tarea.Categoria == idCategoria).toList();
      }
      print("Tareas cargadas: ${tareas.length}");
    } catch (e) {
      tareas = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    cargarTareasCategoria();
    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Agenda(perfil: widget.perfil),
                      ),
                    );
                  }
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

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Tareas $aux",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colores.texto),
                ),
              ),

              BarraAgenda(
                searchController: _searchController,
                crearTarea: crearTarea,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Usted tiene ${tareas.length} tareas",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colores.texto,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Lista de tareas desplazable
              Expanded(
                child: tareas.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                        itemCount: tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = tareas[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CartaTarea(
                              perfil: widget.perfil,
                              orden: index + 1,
                              tarea: tarea,
                              filtro: widget.filtro,
                              onTareaEliminada: () {
                                setState(() {
                                  tareas.removeAt(
                                      index); // Eliminar la tarea de la lista
                                });
                              },
                              onTareaDuplicada: (Tareas nuevaTarea) {
                                setState(() {
                                  tareas.add(nuevaTarea);
                                });
                              },
                              onTareaActualizada: (Tareas tareaActualizada) {
                                setState(() {
                                  tareas[index] = tareaActualizada;
                                });
                              },
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text('No hay tareas disponibles'),
                      ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class BarraAgenda extends StatelessWidget {
  const BarraAgenda(
      {super.key, required this.searchController, required this.crearTarea});
  final TextEditingController searchController;
  final Function(BuildContext) crearTarea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: BarraBusquedaTareas(
            searchController: searchController,
          )),
          const SizedBox(width: 16),
          const SizedBox(width: 8),
          IconoContador(
            svgSrc: Iconos_SVG.masIcono,
            press: () {
              crearTarea(context);
            },
          ),
        ],
      ),
    );
  }
}

class IconoContador extends StatelessWidget {
  const IconoContador({
    super.key,
    required this.svgSrc,
    required this.press,
  });

  final String svgSrc;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46, // Altura del contenedor
            width: 92, // Anchura del contenedor (más largo horizontalmente)
            decoration: BoxDecoration(
              color: Colores.fondoAux,
              borderRadius: BorderRadius.circular(
                  23), // Bordes redondeados para forma ovalada
            ),
            child: SvgPicture.string(
              svgSrc,
              color: Colores.texto,
            ),
          ),
        ],
      ),
    );
  }
}
