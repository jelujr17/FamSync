import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Crear_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Barra_Busqueda_Tareas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Banner_Categorias_Definidas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Carta_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Estados_Tareas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Mis_Categorias.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class Agenda extends StatefulWidget {
  const Agenda({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  List<Tareas> tareas = [];
  List<Tareas> tareasFiltradas = [];
  bool isSearching = false; // Bandera para saber si se está buscando

  bool isLoading = true;
  String errorMessage = '';
  Map<String, int> tareasEstado = {
    'Todas': 0,
    'Programadas': 0,
    'Por hacer': 0,
    'Completadas': 0,
    'Urgentes': 0,
    'En proceso': 0,
  };
  Map<String, int> tareasCategorias = {};
  final TextEditingController _searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        _onSearchChanged); // Escuchar cambios en la barra de búsqueda

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);

      // Cargar tareas y categorías
      tareasProvider.cargarTareas(user!.uid, widget.perfil.PerfilID);
      categoriasProvider.cargarCategorias(user!.uid, widget.perfil.PerfilID);
      setState(() {
        tareas = tareasProvider.tareas; // Lista completa de tareas
        tareasFiltradas =
            List.from(tareas); // Inicialmente igual a todas las tareas
      });
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        isSearching = false; // Si no hay texto, mostrar contenido original
      } else {
        isSearching = true; // Si hay texto, mostrar tareas filtradas
        tareasFiltradas = tareas
            .where((tarea) => tarea.nombre.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto fondoAux
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Perfiles get perfil => widget.perfil;

  void _filterTareas() {
    final query = _searchController.text.toLowerCase();
    final tareasProvider = Provider.of<TareasProvider>(context, listen: true);

    setState(() {
      tareas = tareasProvider.tareas
          .where((tarea) => tarea.nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void _crearTarea(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearTarea(perfil: widget.perfil),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Se realizó una actualización
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tareasProvider =
        Provider.of<TareasProvider>(context, listen: true); // Escuchar cambios
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: true);

    // Actualizar los estados de las tareas cada vez que cambien

    final tareasAux = tareasProvider.tareas;
    if (_searchController.text.isEmpty) {
      tareas = tareasAux;
    } else {
      _filterTareas();
    }

    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Agenda",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colores.texto, fontWeight: FontWeight.bold),
                ),
              ),
              BarraAgenda(
                  searchController: _searchController, crearTarea: _crearTarea),
              const SizedBox(height: 20),
              if (isSearching)
                ListView.builder(
                  shrinkWrap:
                      true, // Permite que el ListView se ajuste al contenido

                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tareasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarea = tareasFiltradas[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CartaTarea(
                        perfil: widget.perfil,
                        orden: index + 1,
                        tarea: tarea,
                        filtro: '',
                        onTareaEliminada: () {
                          setState(() {
                            tareas.removeAt(index);
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
                ),
              if (!isSearching)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: estadosTareas
                        .map(
                          (estado) => Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20, bottom: 20),
                            child: BannerCategoriasDefinidas(
                              perfil: widget.perfil,
                              titulo: estado.titulo,
                              iconSrc: estado.iconSrc,
                              color: estado.color,
                              colorTexto: estado.colorTexto,
                              descripcion: estado.descripcion,
                              cantidadTareas:
                                  tareasProvider.contarTareasPorEstado(
                                      estado.titulo, tareasAux),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 40),
              if (!isSearching)
                Flexible(
                    child: MisCategorias(
                  perfil: widget.perfil,
                )),
              const SizedBox(height: 100),
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
