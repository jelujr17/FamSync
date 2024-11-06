import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CrearEventoPage extends StatefulWidget {
  final Perfiles perfil;

  const CrearEventoPage({super.key, required this.perfil});

  @override
  _CrearEventoPageState createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now();
  int idUsuarioCreador = 1; // Cambia esto según tu lógica
  int idPerfilCreador = 1; // Cambia esto según tu lógica
  List<int> visible = [];
  int idCategoria = 1; // Cambia esto según tu lógica

  final ServicioEventos servicioEventos = ServicioEventos();
  bool eventoRecurrente = false;

  Future<void> _registrarEvento() async {
    if (_formKey.currentState!.validate()) {
      bool resultado = await servicioEventos.registrarEvento(
        nombre,
        descripcion,
        fechaInicio,
        fechaFin,
        idUsuarioCreador,
        idPerfilCreador,
        visible,
        idCategoria,
      );

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado con éxito')),
        );
        Navigator.pop(context); // Cierra el modal después de crear el evento
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el evento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(), // Usa tu clipper aquí
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colores.botonesSecundarios,
            title: const Text(
              'Crear Evento',
              style: TextStyle(fontSize: 24),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contenedor para Nombre y Descripción
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.event_note),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa un nombre';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  nombre = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa una descripción';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  descripcion = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Contenedor para Fechas
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: const Text('Todo el día'),
                              value: eventoRecurrente,
                              onChanged: (bool value) {
                                setState(() {
                                  eventoRecurrente = value;
                                });
                              },
                              activeColor: Colores.principal,
                              inactiveThumbColor: Colores.texto,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            _buildDateTimeField(
                              label: 'Fecha de Inicio',
                              dateTime: fechaInicio,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null &&
                                    pickedDate != fechaInicio) {
                                  setState(() {
                                    fechaInicio = pickedDate;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDateTimeField(
                              label: 'Fecha de Fin',
                              dateTime: fechaFin,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: fechaFin,
                                  firstDate:
                                      fechaInicio, // Cambia esto para que la fecha de fin no sea antes de la de inicio
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null &&
                                    pickedDate != fechaFin) {
                                  setState(() {
                                    fechaFin = pickedDate;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarEvento,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colores.botones,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Crear Evento',
                  style: TextStyle(fontSize: 18, color: Colores.texto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: "${dateTime.toLocal()}".split(' ')[0],
          ),
        ),
      ),
    );
  }
}
