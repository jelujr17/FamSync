import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:intl/intl.dart';

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
    // Cambia la configuración de idioma para Intl a español.
    Intl.defaultLocale = 'es_ES';
  }

  List<Eventos> getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _addEvent(String name, DateTime date) {}

  void _showAddEventDialog() {
    final TextEditingController nameController = TextEditingController();
    DateTime selectedEventDate = selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Evento'),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(DateFormat('yyyy-MM-dd HH:mm').format(selectedEventDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedEventDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedEventDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addEvent(nameController.text, selectedEventDate);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
          SfDateRangePicker(
            initialSelectedDate: selectedDate,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              setState(() {
                selectedDate = args.value;
              });
            },
            
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1, // Configura el lunes como primer día de la semana
            ),
            selectionColor: Colors.blue,
            todayHighlightColor: Colors.orange,
            showTodayButton: false, // Oculta el botón de "Today"
            headerStyle: const DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: getEventsForDay(selectedDate).length,
              itemBuilder: (context, index) {
                final evento = getEventsForDay(selectedDate)[index];
                DateTime fechaInicio = DateFormat("yyyy-MM-dd HH:mm").parse(evento.FechaInicio);

                return ListTile(
                  title: Text(evento.Nombre),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(fechaInicio)),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 36,
        ),
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
