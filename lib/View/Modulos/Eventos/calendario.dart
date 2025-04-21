import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Crear_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Ver/Carta_Evento.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

class Calendario extends StatefulWidget {
  const Calendario({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  CalendarioState createState() => CalendarioState();
}

class CalendarioState extends State<Calendario> {
  bool modo = false; // Modo de vista de tareas (false = "Dia", true = "Meses")

  List<Eventos> eventos = []; // Lista de eventos
  bool isSearching = false; // Bandera para saber si se está buscando

  bool isLoading = true;
  String errorMessage = '';

  void _cambiarModo(bool nuevoModo) {
    setState(() {
      modo = nuevoModo; // Cambiar el modo al nuevo valor
    });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final eventosProvider =
          Provider.of<EventosProvider>(context, listen: false);
      eventosProvider.cargarEventos(
          context, widget.perfil.UsuarioId, widget.perfil.Id);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(context, widget.perfil.UsuarioId, 1);
      setState(() {
        eventos = eventosProvider.eventos; // Actualiza la lista de tareas
        isLoading = false; // Indica que la carga ha terminado
      });
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

  void _crearEvento(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEvento(perfil: widget.perfil),
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
    final eventosProvider =
        Provider.of<EventosProvider>(context, listen: true); // Escuchar cambios
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: true);
    eventos = eventosProvider.eventos;
    final DateTime now = DateTime.now(); // Fecha actual
    final String diaSemana = capitalize(
        DateFormat('EEEE', 'es_ES').format(now)); // Día de la semana en español
    final eventosDiarios = eventos
        .where((evento) =>
            DateTime.parse(evento.FechaInicio).year == now.year &&
            DateTime.parse(evento.FechaInicio).day == now.day &&
            DateTime.parse(evento.FechaInicio).month == now.month)
        .toList(); // Filtrar eventos del día actual

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
                  "Calendario",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colores.texto,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              BarraCalendario(
                searchController: _searchController,
                crearEvento: _crearEvento,
                cambiarModo: (nuevoModo) {
                  _cambiarModo(nuevoModo); // Actualizar el modo
                },
                modo: modo,
              ),
              if (!modo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        diaSemana, // Mostrar el día de la semana con mayúscula
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colores.fondoAux,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              if (!modo) FechaYHoras(fechaActual: now),
              if (!modo)
                Expanded(
                  child: TopRoundedContainer(
                    color: Colores.texto,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: eventosDiarios.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 80),
                                itemCount: eventosDiarios.length,
                                itemBuilder: (context, index) {
                                  final evento = eventosDiarios[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: CartaEvento(
                                      perfil: widget.perfil,
                                      orden: index + 1,
                                      evento: evento,
                                      onEventoEliminado: () {
                                        setState(() {});
                                      },
                                      onEventoActualizado:
                                          (Eventos nuevoEvento) {
                                        setState(() {
                                          print(
                                              "Evento actualizado: $nuevoEvento");
                                          eventosDiarios[index] = nuevoEvento;
                                        });
                                      },
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No hay eventos disponibles'),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class BarraCalendario extends StatelessWidget {
  const BarraCalendario({
    super.key,
    required this.searchController,
    required this.crearEvento,
    required this.cambiarModo,
    required this.modo,
  });

  final TextEditingController searchController;
  final Function(BuildContext) crearEvento;
  final Function(bool) cambiarModo; // Cambiar el modo con un valor booleano
  final bool modo; // Modo de vista de tareas

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón "Baja"
          _buildMododButton(context, 'Hoy', !modo, () {
            cambiarModo(false); // Cambiar a modo "Baja"
          }),
          // Botón "Media"
          _buildMododButton(context, 'Calendario', modo, () {
            cambiarModo(true); // Cambiar a modo "Media"
          }),
          const SizedBox(width: 16),
          IconoContador(
            svgSrc: Iconos_SVG.masIcono,
            press: () {
              crearEvento(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMododButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Llamar al callback al hacer clic
      child: Container(
        width: MediaQuery.of(context).size.width /
            4, // Una cuarta parte del ancho de la pantalla
        height: 50, // Altura fija para los botones
        decoration: BoxDecoration(
          color: isSelected ? Colores.fondoAux : Colores.fondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colores.fondoAux : Colores.fondoAux,
            width: 2,
          ),
        ),
        child: Center(
          // Centrar el texto dentro del botón
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colores.texto : Colores.fondoAux,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
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
            width: 46, // Anchura del contenedor (más largo horizontalmente)
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
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child, // Hacer que el contenido sea desplazable
    );
  }
}

class FechaYHoras extends StatelessWidget {
  final DateTime fechaActual;

  const FechaYHoras({
    super.key,
    required this.fechaActual,
  });

  @override
  Widget build(BuildContext context) {
    // Formatear la fecha
    final String dia = fechaActual.day.toString().padLeft(2, '0');
    final String mes =
        DateFormat('MMM', 'es_ES').format(fechaActual).toUpperCase();

    final String mesAux = fechaActual.month.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Día y mes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$dia.$mesAux",
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colores.texto,
                  height: 1.0, // Ajustar el espaciado entre líneas
                ),
              ),
              Text(
                mes,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colores.texto,
                  height: 1.0, // Ajustar el espaciado entre líneas
                ),
              ),
            ],
          ),
          // Línea divisoria
          Container(
            width: 1, // Ancho de la línea
            height: 100, // Altura de la línea
            color: Colores.fondoAux, // Color de la línea
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Horas de diferentes ubicaciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildEventoUbicacion(
                  "New York", "Reunión con equipo", "3:00 PM"),
              const SizedBox(height: 8),
              _buildEventoUbicacion(
                  "United Kingdom", "Llamada con cliente", "6:00 PM"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventoUbicacion(String ubicacion, String evento, String hora) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          evento,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          "$hora - $ubicacion",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
