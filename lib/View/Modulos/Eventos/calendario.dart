import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Crear_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Ver/Carta_Evento.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_Detalles_Evento.dart';
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
  late ScrollController _scrollController;
  void _cambiarModo(bool nuevoModo) {
    setState(() {
      modo = nuevoModo; // Cambiar el modo al nuevo valor
    });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final eventosProvider =
          Provider.of<EventosProvider>(context, listen: false);
      eventosProvider.cargarEventos(
          context, widget.perfil.UsuarioId, widget.perfil.Id);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(context, widget.perfil.UsuarioId, 1);
      final tareasProvider =
          Provider.of<TareasProvider>(context, listen: false);

      // Cargar tareas y categorías
      tareasProvider.cargarTareas(
          context, widget.perfil.UsuarioId, widget.perfil.Id);
      setState(() {
        eventos = eventosProvider.eventos; // Actualiza la lista de tareas
        isLoading = false; // Indica que la carga ha terminado
      });
      final int indiceDiaActual = _obtenerIndiceDiaActual();
      if (indiceDiaActual != -1) {
        _scrollController.animateTo(
          indiceDiaActual *
              100.0, // Ajusta el desplazamiento según el tamaño del elemento
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  int _obtenerIndiceDiaActual() {
    final DateTime hoy = DateTime.now();
    final diasConEventos = _obtenerDiasConEventos();

    for (int i = 0; i < diasConEventos.length; i++) {
      final DateTime fecha = DateTime.parse(diasConEventos[i]['fecha']);
      if (fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day) {
        return i; // Retorna el índice del día actual
      }
    }
    return -1; // Retorna -1 si no se encuentra el día actual
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
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _obtenerDiasConEventos() {
    final Map<String, List<Eventos>> diasConEventos = {};

    for (var evento in eventos) {
      final String fecha =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(evento.FechaInicio));
      if (!diasConEventos.containsKey(fecha)) {
        diasConEventos[fecha] = [];
      }
      diasConEventos[fecha]!.add(evento);
    }

    return diasConEventos.entries.map((entry) {
      return {
        'fecha': entry.key,
        'eventos': entry.value,
      };
    }).toList();
  }

  Widget _buildDiaConEventos(Map<String, dynamic> diaConEventos, int index) {
    final DateTime fecha = DateTime.parse(diaConEventos['fecha']);
    final List<Eventos> eventosDelDia = diaConEventos['eventos'];

    final String dia = DateFormat('dd').format(fecha);
    final String mes = DateFormat('MMM', 'es_ES').format(fecha).toUpperCase();
    final String diaSemana = DateFormat('EEEE', 'es_ES').format(fecha);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: index.isEven
              ? Colores.fondoAux
              : Colores.texto, // Fondo con opacidad
          borderRadius: BorderRadius.circular(16), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diaSemana,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: index.isOdd ? Colores.fondoAux : Colores.texto,
                      ),
                    ),
                    Text(
                      "$dia $mes",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: index.isOdd ? Colores.fondoAux : Colores.texto,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today,
                    color: index.isOdd ? Colores.fondoAux : Colores.texto),
              ],
            ),
            const SizedBox(height: 16),
            // Eventos del día
            Column(
              children: eventosDelDia.map((evento) {
                final DateTime horaInicio = DateTime.parse(evento.FechaInicio);
                final String horaFormateada =
                    DateFormat('HH:mm').format(horaInicio);

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Permite que el modal ocupe más espacio
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      backgroundColor: Colores.fondoAux.withOpacity(0.95),
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor:
                              0.8, // Ocupa el 90% de la altura de la pantalla
                          child: DetallesEvento(
                            evento: evento,
                            perfil: widget.perfil,
                            onEventoEliminado: () {
                              setState(() {});
                            },
                            onEventoActualizado: (Eventos nuevoEvento) {
                              setState(() {
                                print("Evento actualizado: $nuevoEvento");
                                evento = nuevoEvento;
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Hora del evento
                        Text(
                          horaFormateada,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                index.isOdd ? Colores.fondoAux : Colores.texto,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Nombre del evento
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: index.isOdd
                                  ? Colores.fondoAux
                                  : Colores.texto,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              evento.Nombre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: index.isEven
                                    ? Colores.fondoAux
                                    : Colores.texto,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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
              const SizedBox(height: 40),
              if (modo)
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: _obtenerDiasConEventos().length,
                    itemBuilder: (context, index) {
                      final diaConEventos = _obtenerDiasConEventos()[index];
                      return _buildDiaConEventos(diaConEventos, index);
                    },
                  ),
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
              _buildEventoProximos(context),
            ],
          ),
        ],
      ),
    );
  }

  List<Eventos> _obtenerProximosEventos(BuildContext context) {
    final eventosProvider =
        Provider.of<EventosProvider>(context, listen: false);
    final eventosTotales = eventosProvider.eventos; // Obtener todos los eventos
    final DateTime ahora = DateTime.now();

    // Filtrar eventos cuya fecha de inicio sea posterior al día actual
    final proximosEventos = eventosTotales
        .where((evento) => DateTime.parse(evento.FechaInicio).isAfter(ahora))
        .toList();

    // Ordenar los eventos por fecha de inicio
    proximosEventos.sort((a, b) =>
        DateTime.parse(a.FechaInicio).compareTo(DateTime.parse(b.FechaInicio)));

    // Retornar los dos primeros eventos (o menos si no hay suficientes)
    return proximosEventos.take(2).toList();
  }

  Widget _buildEventoProximos(BuildContext context) {
    List<Eventos> proximosEventos = _obtenerProximosEventos(context);

    if (proximosEventos.isEmpty) {
      return const Text(
        "No hay eventos próximos",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colores.fondoAux.withOpacity(0.6), // Fondo sutil
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.texto.withOpacity(0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: proximosEventos.map((evento) {
            final DateTime fechaInicio = DateTime.parse(evento.FechaInicio);
            final String fechaFormateada =
                DateFormat('dd/MM/yyyy').format(fechaInicio);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    evento.Nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colores.texto,
                    ),
                  ),
                  Text(
                    fechaFormateada,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colores.fondo,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}
