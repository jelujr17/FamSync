import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Calendario/Eventos/crearEvento.dart';
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
      List<Eventos> eventos = await _servicioEventos.getEventos(
          widget.perfil.Id, widget.perfil.UsuarioId);
      setState(() {
        _listaDeEventos = eventos.map((evento) {
          return NeatCleanCalendarEvent(
            evento.Nombre,
            description: evento.Descripcion,
            startTime: DateTime.parse(
                evento.FechaInicio), // Asegúrate de que el formato sea correcto
            endTime: DateTime.parse(evento.FechaFin),
            color: Colors
                .blue, // Puedes definir un color o basarlo en la categoría
            isAllDay: false, // Ajusta según tus necesidades
          );
        }).toList();
      });
    } catch (e) {
      print('Error al cargar eventos: $e');
    }
  }

  void _showPopup1() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Esto permite controlar el tamaño de la ventana emergente
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)), // Bordes redondeados en la parte superior
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9, // Ajusta el tamaño inicial al 90% de la pantalla
        minChildSize: 0.4, // Tamaño mínimo al que se puede reducir la hoja
        maxChildSize: 0.95, // Tamaño máximo al que se puede expandir la hoja
        builder: (BuildContext context, ScrollController scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0)), // Bordes redondeados
            child: Container(
              color: Colors.white, // Cambia el color de fondo según lo necesites
              child: CrearEventoPage(
                perfil: widget.perfil,
              ),
            ),
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
            primaryColor: Colores
                .botones, // Cambia el color del fondo de los elementos principales
            iconTheme: const IconThemeData(
              color: Colors.green, // Cambia el color de las flechas
            ),
          ),
          child: Calendar(
            topRowIconColor: Colores.botones,
            startOnMonday: true,
            weekDays: const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
            eventsList: _listaDeEventos,
            isExpandable: true,
            selectedColor: Colores.principal,
            todayColor: Colores.botones,
            defaultDayColor: Colores.texto,
            datePickerDarkTheme: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.blue,
                onPrimary: Colors.yellow,
                surface: Colors.grey,
                onSurface: Colors.yellow,
              ),
            ),
            hideArrows: false,
            isExpanded: true,
            expandableDateFormat: "EEEE, d 'de' MMMM 'del' yyyy",
            locale: 'es_ES',
            todayButtonText: 'Calendario',
            allDayEventText: 'Todo el día',
            onEventSelected: (value) {
              print('Evento seleccionado: ${value.summary}');
            },
            onDateSelected: (value) {
              print('Fecha seleccionada: $value');
            },
            showEvents: mostrarEventos,
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
        pagina: 1,
        perfil: widget.perfil,
      ),
    );
  }
}
