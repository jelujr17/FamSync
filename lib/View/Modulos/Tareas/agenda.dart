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
    Filtrado filtrado1 =
        Filtrado(Id: 1, Nombre: 'Todas', Conteo: tareasObtenidas.length);
    Filtrado filtrado2 = Filtrado(Id: 2, Nombre: 'Programadas', Conteo: 0);
    Filtrado filtrado3 = Filtrado(Id: 3, Nombre: 'Por hacer', Conteo: 0);
    Filtrado filtrado4 = Filtrado(Id: 4, Nombre: 'Completadas', Conteo: 0);
    Filtrado filtrado5 = Filtrado(Id: 5, Nombre: 'Urgente', Conteo: 0);

    print("kafnkafkwnfanvanw ${tareasObtenidas.length}");
    for (int i = 0; i < tareasObtenidas.length; i++) {
      if (tareasObtenidas[i].IdEvento != null) {
        filtrado2.Conteo++;
      } else if (tareasObtenidas[i].Progreso == 0) {
        filtrado3.Conteo++;
      } else if (tareasObtenidas[i].Progreso == 100) {
        filtrado4.Conteo++;
      } else if (tareasObtenidas[i].Prioridad == 3) {
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

  @override
  Widget build(BuildContext context) {
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
              decoration: InputDecoration(
                hintText: "Buscar eventos...",
                prefixIcon: const Icon(Icons.search, color: Colores.texto),
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
          // Lista de categorías en un GridView
          Expanded(
            child: filtros.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio:
                          1.8, // Reducir altura de los contenedores
                    ),
                    itemCount: filtros.length,
                    itemBuilder: (context, index) {
                      final categoria = filtros[index];

                      return GestureDetector(
                        onTap: () {
                          // Filtrar tareas según la categoría seleccionada

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TareasPage(
                                perfil: widget.perfil,
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
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 36, // Reducir tamaño del icono
                                color: Colores.botonesSecundarios,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categoria.Nombre,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${categoria.Conteo} tareas",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colores.texto,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
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

  Filtrado({
    required this.Id,
    required this.Nombre,
    required this.Conteo,
  });
}
