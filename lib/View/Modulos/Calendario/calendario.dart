// ignore_for_file: unused_field

import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class Calendario extends StatefulWidget {
  final Perfiles perfil;

  const Calendario({super.key, required this.perfil});

  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<Calendario> {
  bool mostrarEventos = true;

  final List<NeatCleanCalendarEvent> _eventosDelDia = [
    NeatCleanCalendarEvent(
      'Evento A',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
      description: 'Un evento especial',
      color: Colors.blue[700],
    ),
  ];

  final List<NeatCleanCalendarEvent> _listaDeEventos = [
    NeatCleanCalendarEvent(
      'Evento Multidía A',
      description: 'Descripción de prueba',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 12, 0),
      color: Colors.orange,
      isMultiDay: true,
    ),
    NeatCleanCalendarEvent('Evento X',
        description: 'Descripción de prueba',
        startTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 10, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 11, 30),
        color: Colors.lightGreen,
        isAllDay: false,
        isDone: true,
        icon: 'assets/event1.jpg',
        wide: false),
    NeatCleanCalendarEvent('Evento Todo el Día B',
        description: 'Descripción de prueba',
        startTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - 2, 14, 30),
        endTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day + 2, 17, 0),
        color: Colors.pink,
        isAllDay: true,
        icon: 'assets/event1.jpg',
        wide: false),
    NeatCleanCalendarEvent(
      'Evento Normal D',
      description: 'Descripción de prueba',
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 14, 30),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0),
      color: Colors.indigo,
      wide: true,
      icon: 'assets/events.jpg',
    ),
    NeatCleanCalendarEvent(
      'Evento Normal E',
      description: 'Descripción de prueba',
      startTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 45),
      endTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
      color: Colors.indigo,
      wide: true,
      icon: 'assets/profile.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Forzar la selección de hoy al cargar por primera vez, para mostrar la lista de eventos de hoy.
    _manejarNuevaFecha(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));
  }

  Widget celdaEvento(BuildContext context, NeatCleanCalendarEvent event,
      String start, String end) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child:
            Text('Evento del Calendario: ${event.summary} de $start a $end'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Calendar(
          startOnMonday: true,
          weekDays: const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
          eventsList: _listaDeEventos,
          isExpandable: true,
          eventDoneColor: Colors.deepPurple,
          selectedColor: Colores.principal,
          selectedTodayColor: Colores.principal,
          todayColor: Colors.teal,
          defaultDayColor: Colores.texto,
          defaultOutOfMonthDayColor: Colors.grey,
          datePickerDarkTheme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.yellow,
              surface: Colors.grey,
              onSurface: Colors.yellow,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          datePickerLightTheme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.teal,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colores.texto,
              ),
            ),
          ),
          eventColor: null,
          locale: 'es_ES', // Cambié a español
          todayButtonText: 'Hoy',
          allDayEventText: 'Todo el día',
          multiDayEndText: 'Fin',
          isExpanded: true,
          expandableDateFormat: 'EEEE, dd  MMMM  yyyy',
          onEventSelected: (value) {
            print('Evento seleccionado: ${value.summary}');
          },
          onEventLongPressed: (value) {
            print('Evento presionado por mucho tiempo: ${value.summary}');
          },
          onDateSelected: (value) {
            print('Fecha seleccionada: $value');
          },
          onRangeSelected: (value) {
            print('Rango seleccionado: ${value.from} - ${value.to}');
          },
          datePickerType: DatePickerType.date,
          dayOfWeekStyle: const TextStyle(
              color: Colores.texto, fontWeight: FontWeight.w800, fontSize: 11),
          showEventListViewIcon: true,
          showEvents: mostrarEventos,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            print("sfagEBRAB RBEBEBAEF");
          });
        },
        backgroundColor: Colores.botones, // Color del ícono
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colores.texto,
          size: 32,
        ), // Esto asegura que sea un círculo
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: PageController(), pagina: 1, perfil: widget.perfil),
    );
  }

  void _manejarNuevaFecha(date) {
    print('Fecha seleccionada: $date');
  }
}
