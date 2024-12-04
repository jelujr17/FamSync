import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/View/Modulos/Calendario/Eventos/verDetallesEvento.dart';
import 'package:famsync/View/Modulos/Tareas/Categorias/tareas.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class Agenda extends StatefulWidget {
  final Perfiles perfil; // Identificador del perfil del usuario

  const Agenda({super.key, required this.perfil});

  @override
  State<Agenda> createState() => AgendaState();
}

class AgendaState extends State<Agenda> {
  List<Categorias> categorias = [];
  Map<int, int> conteoTareas = {};
  String filtroEventos = ""; // Controlador del texto de búsqueda
  List<Tareas> tareasObtenidas = [];
  final TextEditingController _searchController = TextEditingController();
  List<Filtrado> filtros = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      // Obtener categorías por módulo
      List<Categorias> categoriasObtenidas = await ServiciosCategorias()
          .getCategoriasByModulo(widget.perfil.UsuarioId, 5);

      // Obtener tareas
      tareasObtenidas = await ServicioTareas().getTareas(widget.perfil.Id);

      setState(() {
        categorias = categoriasObtenidas;
        cargarInformacionFilto();
      });

      print(filtros[0].Conteo);
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  void cargarInformacionFilto() {
    //creamos los filtros predeterminados
    Filtrado filtrado1 = Filtrado(
        Id: 1,
        Nombre: 'Todas',
        Conteo: tareasObtenidas.length,
        Icono: const Icon(
          Icons.all_inbox,
          color: Colores.principal,
        ));
    Filtrado filtrado2 = Filtrado(
        Id: 2,
        Nombre: 'Programadas',
        Conteo: 0,
        Icono: const Icon(
          Icons.calendar_month,
          color: Colores.botonesSecundarios,
        ));
    Filtrado filtrado3 = Filtrado(
        Id: 3,
        Nombre: 'Por hacer',
        Conteo: 0,
        Icono: const Icon(
          Icons.start,
          color: Colores.botones,
        ));
    Filtrado filtrado4 = Filtrado(
        Id: 4,
        Nombre: 'Completadas',
        Conteo: 0,
        Icono: const Icon(
          Icons.done,
          color: Colores.hecho,
        ));
    Filtrado filtrado5 = Filtrado(
        Id: 5,
        Nombre: 'Urgente',
        Conteo: 0,
        Icono: const Icon(
          Icons.warning,
          color: Colores.eliminar,
        ));

    for (int i = 0; i < tareasObtenidas.length; i++) {
      if (tareasObtenidas[i].IdEvento != null) {
        filtrado2.Conteo++;
      }
      if (tareasObtenidas[i].Progreso == 0) {
        filtrado3.Conteo++;
      }
      if (tareasObtenidas[i].Progreso == 100) {
        filtrado4.Conteo++;
      }
      if (tareasObtenidas[i].Prioridad == 3) {
        filtrado5.Conteo++;
      }
    }
    setState(() {
      filtros.add(filtrado1);
      filtros.add(filtrado2);
      filtros.add(filtrado3);
      filtros.add(filtrado4);
      filtros.add(filtrado5);
    });
  }

  List<Tareas> enviarTareas(int opcion) {
    switch (opcion) {
      case 1:
        return tareasObtenidas;
      case 2:
        return tareasObtenidas
            .where((element) => element.IdEvento != null)
            .toList();
      case 3:
        return tareasObtenidas
            .where((element) => element.Progreso == 0)
            .toList();
      case 4:
        return tareasObtenidas
            .where((element) => element.Progreso == 100)
            .toList();
      case 5:
        return tareasObtenidas
            .where((element) => element.Prioridad == 3)
            .toList();
      default:
        return [];
    }
  }

  Widget buildFiltroCard(Filtrado categoria) {
    return GestureDetector(
      onTap: () {
        List<Tareas> tareas = enviarTareas(categoria.Id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TareasPage(
              perfil: widget.perfil,
              tareas: tareas,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colores.fondo,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colores.principal,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            categoria.Icono,
            const SizedBox(height: 6),
            Text(
              categoria.Nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${categoria.Conteo} tareas",
              style: const TextStyle(
                fontSize: 11,
                color: Colores.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lista filtrada de tareas basada en la barra de búsqueda
    List<Tareas> tareasFiltradas = filtroEventos.isEmpty
        ? [] // Si no hay filtro, no se muestran tareas aquí
        : tareasObtenidas
            .where((tarea) => tarea.Nombre.toLowerCase()
                .contains(filtroEventos)) // Filtrar por nombre
            .toList();

    return Scaffold(
      backgroundColor: Colores.fondoAux,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(),
          child: AppBar(
            automaticallyImplyLeading:
                false, // Evita que se muestre el icono de retroceso
            backgroundColor: Colores.principal,
            title: const Center(
              child: Text(
                'Agenda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  filtroEventos = value.toLowerCase(); // Actualizar filtro
                });
              },
              controller:
                  _searchController, // Controlador para manejar el texto
              decoration: InputDecoration(
                hintText: "Buscar eventos...",
                prefixIcon: const Icon(Icons.search, color: Colores.texto),
                suffixIcon: filtroEventos.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.highlight_off, color: Colores.texto),
                        onPressed: () {
                          _searchController.clear(); // Limpiar texto
                          setState(() {
                            filtroEventos = ""; // Reiniciar filtro
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colores.fondo,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          // Mostrar resultados de búsqueda o las categorías
          filtroEventos.isNotEmpty
              ? Expanded(
                  child: tareasFiltradas.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: tareasFiltradas.length,
                          itemBuilder: (context, index) {
                            final tarea = tareasFiltradas[index];
                            return ListTile(
                              title: Text(
                                tarea.Nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Progreso: ${tarea.Progreso}%"),
                              trailing: tarea.Prioridad == 3
                                  ? const Icon(
                                      Icons.warning,
                                      color: Colores.eliminar,
                                    )
                                  : null,
                              onTap: () {
                                // Acción al seleccionar una tarea
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No se encontraron tareas",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colores.texto,
                            ),
                          ),
                        ),
                )
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio:
                          2.5, // Incrementar para reducir la altura
                    ),
                    itemCount: filtros.length,
                    itemBuilder: (context, index) =>
                        buildFiltroCard(filtros[index]),
                  ),
                ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        pageController: PageController(),
        pagina: 0,
        perfil: widget.perfil,
      ),
    );
  }
}

class Filtrado {
  final int Id;
  final String Nombre;
  int Conteo;
  final Icon Icono;

  Filtrado({
    required this.Id,
    required this.Nombre,
    required this.Conteo,
    required this.Icono,
  });
}
