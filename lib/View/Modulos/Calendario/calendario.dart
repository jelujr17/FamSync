import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Calendario/Eventos/crearEvento.dart';
import 'package:famsync/View/Modulos/Calendario/Eventos/verDetallesEvento.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class Calendario extends StatefulWidget {
  final Perfiles perfil;

  const Calendario({super.key, required this.perfil});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<Calendario> {
  bool mostrarEventos = true;
  List<NeatCleanCalendarEvent> _listaDeEventos = [];
  List<String> aux = ["de", "del"];

  final ServicioEventos _servicioEventos =
      ServicioEventos(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    _cargarEventos(); // Cargar eventos al iniciar
  }

  Future<void> _cargarEventos() async {
    try {
      List<Categorias> categorias = await ServiciosCategorias()
          .getCategoriasByModulo(widget.perfil.Id, 1);
      print("Número de categorias obtenidas: ${categorias.length}");
      List<Eventos> eventos = await _servicioEventos.getEventos(
        widget.perfil.UsuarioId,
        widget.perfil.Id,
      );
      print("La verdadera vuelta");
      setState(() {
        _listaDeEventos = eventos.map((evento) {
          final categoria = categorias.firstWhere(
            (cat) => cat.Id == evento.IdCategoria,
          );

          return NeatCleanCalendarEvent(
            evento.Nombre,
            description: evento.Descripcion,
            startTime: DateTime.parse(evento.FechaInicio),
            endTime: DateTime.parse(evento.FechaFin),
            color: Color(int.parse("0xFF${categoria.Color}")),
          );
        }).toList();

        // Ordena los eventos por la hora de inicio
        _listaDeEventos.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    } catch (e) {
      print('Error al cargar eventos: $e');
    }
  }

  void _showPopup1() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite controlar el tamaño de la ventana emergente
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9, // Tamaño inicial al 90% de la pantalla
          minChildSize: 0.4, // Tamaño mínimo al que se puede reducir la hoja
          maxChildSize: 0.95, // Tamaño máximo al que se puede expandir la hoja
          builder: (BuildContext context, ScrollController scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25.0)),
              child: Container(
                color: Colors.white,
                child: CrearEventoPage(
                  perfil: widget.perfil,
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _cargarEventos(); // Recargar eventos al cerrar la ventana emergente
      });
    });
  }

  void _showPopup(NeatCleanCalendarEvent evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Esto permite controlar el tamaño de la ventana emergente
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize:
              0.6, // Ajusta el tamaño inicial (0.6 significa 60% de la pantalla)
          minChildSize: 0.4, // Tamaño mínimo al que se puede reducir la hoja
          maxChildSize: 0.9, // Tamaño máximo al que se puede expandir la hoja
          builder: (BuildContext context, ScrollController scrollController) {
            return DetalleEventoPage(
              evento: evento,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Theme(
          data: ThemeData(
            primaryColor: Colores.botones,
            iconTheme: const IconThemeData(color: Colors.green),
          ),
          child: Column(
            children: [
              Expanded(
                child: Calendar(
                  topRowIconColor: Colores.botones,
                  startOnMonday: true,
                  weekDays: const [
                    'Lun',
                    'Mar',
                    'Mié',
                    'Jue',
                    'Vie',
                    'Sáb',
                    'Dom'
                  ],
                  eventsList: _listaDeEventos,
                  isExpandable: true,
                  selectedColor: Colores.principal,
                  todayColor: Colores.botones,
                  defaultDayColor: Colores.texto,
                  hideArrows: false,
                  isExpanded: true,
                  expandableDateFormat: "EEEE, d 'de' MMMM 'del' yyyy",
                  locale: 'es_ES',
                  todayButtonText: 'Calendario',
                  allDayEventText: 'Todo el día',
                  onEventSelected: (value) {
                    print('Evento seleccionado: ${value.summary}');
                    _showPopup(value);
                  },
                  onDateSelected: (value) {
                    print('Fecha seleccionada: $value');
                  },
                  showEvents: mostrarEventos,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPopup1();
        },
        backgroundColor: Colores.botones,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colores.texto, size: 32),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        pageController: PageController(),
        pagina: 0,
        perfil: widget.perfil,
      ),
    );
  }
}
