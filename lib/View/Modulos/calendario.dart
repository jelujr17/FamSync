import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/navegacion.dart';

class Calendario extends StatefulWidget {
  final Perfiles perfil;

  const Calendario({super.key, required this.perfil});

  @override
  CalendarioScreenState createState() => CalendarioScreenState();
}

class CalendarioScreenState extends State<Calendario> {
  final PageController _pageController = PageController(initialPage: 0);
  late NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Definimos la función _onPageChanged
  void _onPageChanged(int index) {
    setState(() {
      _controller.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                // Acción al seleccionar un día
                print('Día seleccionado: $selectedDay');
              },
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _pageController,
        controller: _controller,
        perfil: widget.perfil, 
      ),
    );
  }
}
