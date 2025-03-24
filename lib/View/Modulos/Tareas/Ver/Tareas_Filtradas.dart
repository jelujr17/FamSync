import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Barra_Busqueda_Tareas.dart';
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
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTareas);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Cargar tareas y categorías desde los providers
    final tareasProvider = Provider.of<TareasProvider>(context, listen: false);
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);

    tareasProvider.cargarTareas(widget.perfil.UsuarioId, widget.perfil.Id);
    categoriasProvider.cargarCategorias(widget.perfil.UsuarioId, 5);

    // Obtener las tareas filtradas según la categoría
    obtenerTareasCategoria();
  }

  void _filterTareas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      tareas = tareasAux
          .where((tarea) => tarea.Nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void obtenerTareasCategoria() {
    final tareasProvider = Provider.of<TareasProvider>(context, listen: false);
    tareasAux = tareasProvider.tareas;

    switch (widget.filtro) {
      case "Todas":
        tareas = tareasAux;
        break;
      case "Programadas":
        tareas = tareasAux.where((tarea) => tarea.IdEvento != null).toList();
        break;
      case "Por hacer":
        tareas = tareasAux.where((tarea) => tarea.Progreso == 0).toList();
        break;
      case "Completadas":
        tareas = tareasAux.where((tarea) => tarea.Progreso == 100).toList();
        break;
      case "Urgentes":
        tareas = tareasAux.where((tarea) => tarea.Prioridad == 3).toList();
        break;
      case "En proceso":
        tareas = tareasAux
            .where((tarea) => tarea.Progreso > 0 && tarea.Progreso < 100)
            .toList();
        break;
      default:
        tareas = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(
                            context); // Navega hacia atrás si hay una página en la pila
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Agenda(perfil: widget.perfil),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Tareas ${widget.filtro}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      BarraAgenda(
                        searchController: _searchController,
                        crearTarea: _crearTarea,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Usted tiene ${tareas.length} tareas",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 20),
                      tareas.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tareas.length,
                              itemBuilder: (context, index) {
                                final tarea = tareas[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CartaTarea(
                                    title: tarea.Nombre,
                                    company: "ID: ${tarea.Id}",
                                    date: "Prioridad: ${tarea.Prioridad}",
                                    progress: tarea.Progreso,
                                    remainingTime:
                                        "Estado: ${tarea.Descripcion}",
                                    avatars: const [
                                      "https://randomuser.me/api/portraits/women/1.jpg"
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.task_alt,
                                      size: 60, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "¡No tienes tareas pendientes!",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black54),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Crea tu primera tarea ahora.",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black38),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _crearTarea(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Placeholder(), // Reemplaza con tu página de creación
      ),
    );

    if (result == true) {
      obtenerTareasCategoria(); // Actualiza las tareas después de crear una nueva
    }
  }
}

class CartaTarea extends StatelessWidget {
  final String title;
  final String company;
  final String date;
  final int progress;
  final String remainingTime;
  final List<String> avatars;

  const CartaTarea({
    super.key,
    required this.title,
    required this.company,
    required this.date,
    required this.progress,
    required this.remainingTime,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.more_vert),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            company,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: avatars
                .map((url) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(url),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: Colores.botones,
                ),
              ),
              const SizedBox(width: 8),
              Text("$progress%", style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remainingTime,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}



class BarraAgenda extends StatelessWidget {
  const BarraAgenda(
      {super.key, required this.searchController, required this.crearTarea});
  final TextEditingController searchController;
  final Function(BuildContext) crearTarea;

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto negro
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

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
    this.numOfitem = 0,
    required this.press,
  });

  final String svgSrc;
  final int numOfitem;
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
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
