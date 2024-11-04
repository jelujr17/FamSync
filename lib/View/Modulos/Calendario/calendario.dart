import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';

class Calendario extends StatefulWidget {
  final Perfiles perfil;

  const Calendario({super.key, required this.perfil});

  @override
  CalendarioScreenState createState() => CalendarioScreenState();
}

class CalendarioScreenState extends State<Calendario> {
  DateTime selectedDate = DateTime.now();
  late Map<DateTime, List<Eventos>> events;

  @override
  void initState() {
    super.initState();
    events = {}; // Inicializa el mapa de eventos
  }

  // Método actualizado para incluir el año
  String _formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'es_ES').format(date).capitalize(); // Formato "Noviembre 2024"
  }

  // Método para obtener los días de la semana en formato abreviado
  List<String> _getAbbreviatedDaysOfWeek() {
    return ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Encabezado personalizado para el mes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              _formatMonth(selectedDate),
              style: const TextStyle(fontSize: 40, color: Colores.principal),
            ),
          ),
          // Encabezado de los días de la semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _getAbbreviatedDaysOfWeek().map((day) {
                return Expanded(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colores.texto,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          TableCalendar<Eventos>(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay; // Actualiza la fecha seleccionada
              });
            },
            eventLoader: (day) => events[day] ?? [], // Carga los eventos para el día
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colores.botones,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colores.principal,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Oculta el botón de formato
              leftChevronVisible: false, // Oculta el icono de flecha izquierda
              rightChevronVisible: false, // Oculta el icono de flecha derecha
              headerPadding: EdgeInsets.zero, // Espaciado cero para el encabezado
              titleCentered: false, // Alinea el texto del mes a la izquierda
            ),
            locale: 'es_ES', // Configura el locale a español
            startingDayOfWeek: StartingDayOfWeek.monday, // Semana comienza el lunes
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        pageController: PageController(),
        pagina: 1,
        perfil: widget.perfil,
      ),
    );
  }
}

// Extensión para capitalizar la primera letra de un String
extension StringCasingExtension on String {
  String capitalize() {
    if (this.isEmpty) return ''; // Asegúrate de que el string no esté vacío
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
