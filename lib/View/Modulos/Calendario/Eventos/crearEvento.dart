import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Importa la librería para el selector de colores

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
  Color colorSeleccionado =
      Colores.principal; // Inicializa con un color predeterminado
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final ServicioEventos servicioEventos = ServicioEventos();
  bool eventoRecurrente = false;
  List<String> nombresCategorias = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    obtenerCategorias();
    obtenerNombresCategorias();
  }

  void obtenerCategorias() async {
    categoriasDisponibles =
        await ServiciosCategorias().getCategoriasByModulo(widget.perfil.Id, 2);
    obtenerNombresCategorias(); // Asegúrate de que esto se llame después de obtener las tiendas

    setState(() {});
  }

  void obtenerNombresCategorias() {
    nombresCategorias = categoriasDisponibles.map((e) => e.Nombre).toList();
    print(nombresCategorias);
  }

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(
        nombresCategorias); // Asegúrate de que nombresTienda esté correctamente poblada

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

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
        colorSeleccionado.toString(), // Guarda el color seleccionado
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
        color: Colores.fondo,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: Colores.fondoAux,
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
                      // Campo para seleccionar color (con el mismo estilo)
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: DropDownSearchFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Selecciona una categoria',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.store),
                            ),
                            controller: _dropdownSearchFieldController,
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern); // Debe devolver una lista de nombres de tienda
                          },
                          itemBuilder: (context, String suggestion) {
                            // Mapa de categorías con sus colores
                            Map<String, Color> categoriasColores = {};
                            for (int i = 0;
                                i < categoriasDisponibles.length;
                                i++) {
                              // Asegúrate de que el color se convierte correctamente
                              String colorHex = categoriasDisponibles[i].Color;
                              Color categoriaColor = Color(int.parse("0xFF" +
                                  colorHex)); // Agregar '0xFF' para opacidad completa
                              categoriasColores[categoriasDisponibles[i]
                                  .Nombre] = categoriaColor;
                            }

                            // Obtiene el color para la categoría seleccionada
                            Color categoriaColor =
                                categoriasColores[suggestion] ?? Colors.grey;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: categoriaColor,
                                radius: 12,
                              ),
                              title: Text(suggestion),
                            );
                          },
                          itemSeparatorBuilder: (context, index) {
                            return const Divider();
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (String suggestion) {
                            _dropdownSearchFieldController.text = suggestion;
                            categoriaSeleccionada =
                                suggestion; // Actualiza la variable de tienda seleccionada
                          },
                          suggestionsBoxController: suggestionBoxController,
                          validator: (value) => value!.isEmpty
                              ? 'Por favor selecciona una categoria'
                              : null,
                          displayAllSuggestionWhenTap: true,
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Contenedor para las fechas y "Todo el día"
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Campo "Todo el día" dentro del mismo contenedor
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Todo el día',
                                border: OutlineInputBorder(),
                              ),
                              child: SwitchListTile(
                                title: const Text('Todo el día'),
                                value: eventoRecurrente,
                                onChanged: (bool value) {
                                  setState(() {
                                    eventoRecurrente = value;
                                  });
                                },
                                activeColor: Colores.principal,
                                inactiveThumbColor: Colores.texto,
                                inactiveTrackColor: Colores.fondoAux,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDateTimeField(
                              label: 'Fecha de Inicio',
                              dateTime: fechaInicio,
                              isAllDay: eventoRecurrente,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() {
                                  fechaInicio = newDate;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDateTimeField(
                              label: 'Fecha de Fin',
                              dateTime: fechaFin,
                              isAllDay: eventoRecurrente,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() {
                                  fechaFin = newDate;
                                });
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
    required bool isAllDay,
    required ValueChanged<DateTime> onDateTimeChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        // Mostrar selector de fecha
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          if (isAllDay) {
            // Si es un evento de todo el día, solo seleccionamos la fecha
            onDateTimeChanged(pickedDate);
          } else {
            // Si no es un evento de todo el día, seleccionamos la fecha y hora
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(dateTime),
            );
            if (pickedTime != null) {
              final newDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              onDateTimeChanged(newDateTime);
            }
          }
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: isAllDay
                ? "${dateTime.toLocal()}".split(' ')[0]
                : "${dateTime.toLocal()}".split('.')[0],
          ),
        ),
      ),
    );
  }
}
