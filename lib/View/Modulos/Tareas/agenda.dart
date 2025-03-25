import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Barra_Busqueda_Tareas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Banner_Categorias_Definidas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Banner_Mis_Categorias.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Estados_Tareas.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Tareas_Filtradas.dart';
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

class Agenda extends StatefulWidget {
  const Agenda({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  List<Tareas> tareas = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);
      tareasProvider.cargarTareas(widget.perfil.UsuarioId, widget.perfil.Id);

      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(widget.perfil.UsuarioId, 5);
    });
  }

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto negro
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Perfiles get perfil => widget.perfil;

  void _filterTareas() {
    final query = _searchController.text.toLowerCase();
    final tareasProvider = Provider.of<TareasProvider>(context, listen: true);

    setState(() {
      tareas = tareasProvider.tareas
          .where((tarea) => tarea.Nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void _crearTarea(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Placeholder(),
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
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: true);
    final tareasProvider = Provider.of<TareasProvider>(context, listen: true);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Agenda",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colores.amarillo, fontWeight: FontWeight.bold),
                  ),
                ),
                BarraAgenda(
                    searchController: _searchController,
                    crearTarea: _crearTarea),
                const SizedBox(height: 20),
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Mis categorías",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colores.amarillo, fontWeight: FontWeight.bold),
                  ),
                ),
                if (categoriasProvider.categorias.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ...categoriasProvider.categorias.map((categoria) => Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: SecondaryCourseCard(
                          title: categoria.Nombre,
                          iconsSrc: "assets/icons/code.svg",
                          colorl: Color(int.parse("0xFF${categoria.Color}")),
                          textColor: getContrastingTextColor(Color(int.parse(
                              "0xFF${categoria.Color}"))), // Color del texto dinámico
                          onIconPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TareasFiltradas(
                                  perfil: widget.perfil,
                                  filtro: categoria.Nombre,
                                ), // Página de destino
                              ),
                            );
                          },
                        ),
                      )),
                const SizedBox(height: 100),
              ],
            ),
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
              color: Colores.negro,
              borderRadius: BorderRadius.circular(
                  23), // Bordes redondeados para forma ovalada
            ),
            child: SvgPicture.string(
              svgSrc,
              color: Colores.amarillo,
            ),
          ),
        ],
      ),
    );
  }
}
