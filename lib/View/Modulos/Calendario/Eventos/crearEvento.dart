import 'package:famsync/Model/perfiles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart'; // Importar la biblioteca

class CrearEventoPage extends StatefulWidget {
    final Perfiles perfil;

  const CrearEventoPage({super.key, required this.perfil});
  @override
  _CrearEventoPageState createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  List<Calendar> _calendars = [];

  @override
  void initState() {
    super.initState();
    _fetchCalendars(); // Cargar los calendarios disponibles
  }

  Future<void> _fetchCalendars() async {
    // Obtener la lista de calendarios disponibles
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    setState(() {
      _calendars = calendarsResult.data ?? [];
    });
  }

  Future<void> _selectFecha(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? (_fechaInicio ?? DateTime.now()) : (_fechaFin ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (_fechaInicio ?? DateTime.now())) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _crearEvento() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaInicio != null && _fechaFin != null) {
        // Crear el evento en el calendario
     

        if (true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento creado en el calendario')),
          );
          Navigator.pop(context); // Regresar a la página anterior
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear el evento en el calendario')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione las fechas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del evento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la descripción';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha de Inicio'),
                      subtitle: Text(_fechaInicio == null
                          ? 'No seleccionada'
                          : DateFormat('yyyy-MM-dd').format(_fechaInicio!)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectFecha(context, true),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha de Fin'),
                      subtitle: Text(_fechaFin == null
                          ? 'No seleccionada'
                          : DateFormat('yyyy-MM-dd').format(_fechaFin!)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectFecha(context, false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearEvento,
                child: const Text('Crear Evento en Calendario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
