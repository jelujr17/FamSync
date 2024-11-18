import 'dart:io';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
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
  List<int> visible = [];
  Color colorSeleccionado =
      Colores.principal; // Inicializa con un color predeterminado
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final ServicioEventos servicioEventos = ServicioEventos();
  bool eventoRecurrente = false;
  List<String> nombresCategorias = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  Map<String, Color> colorNombreCategoria = {};
  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  Map<String, Color> categoriasColores = {}; // Definir categoriasColores aquí
  int?
      idCategoriaSeleccionada; // Para almacenar el ID de la categoría seleccionada
  List<Perfiles> participantesSeleccionados = [];
  List<Perfiles> participantesDisponibles = [];

  @override
  void initState() {
    super.initState();
    obtenerCategorias();
    obtenerParticipantes();
    obtenerNombresCategorias();
  }

  void obtenerParticipantes() async {
    // Ejemplo: Obtén la lista desde tu API
    participantesDisponibles =
        await ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId);

    setState(() {});
  }

  void _seleccionarParticipantes() async {
    // Mostrar el diálogo de selección de participantes
    final seleccionados = await showDialog<List<Perfiles>>(
      context: context,
      builder: (BuildContext context) {
        List<Perfiles> seleccionadosTemp =
            List.from(participantesSeleccionados);

        return AlertDialog(
          title: const Text('Selecciona participantes'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: participantesDisponibles.length,
                  itemBuilder: (context, index) {
                    final perfil = participantesDisponibles[index];
                    final seleccionado = seleccionadosTemp.contains(perfil);

                    return ListTile(
                      title: Text(
                        perfil.Nombre,
                        style: const TextStyle(
                          color: Colores.texto,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: perfil.FotoPerfil.isNotEmpty &&
                                    File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')
                                        .existsSync()
                                ? FileImage(File(
                                    'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}'))
                                : null,
                            child: perfil.FotoPerfil.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          if (seleccionado)
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child:
                                  Icon(Icons.check_circle, color: Colors.green),
                            ),
                        ],
                      ),
                      tileColor: seleccionado
                          ? Colores.principal.withOpacity(0.2)
                          : null,
                      onTap: () {
                        setState(() {
                          if (seleccionado) {
                            seleccionadosTemp.remove(perfil);
                          } else {
                            seleccionadosTemp.add(perfil);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.pop(context, seleccionadosTemp),
            ),
          ],
        );
      },
    );

    // Si se aceptaron cambios, actualiza la lista de participantes seleccionados
    if (seleccionados != null) {
      setState(() {
        participantesSeleccionados = seleccionados;
      });
    }
  }

  void obtenerCategorias() async {
    categoriasDisponibles =
        await ServiciosCategorias().getCategoriasByModulo(widget.perfil.Id, 1);

    // Llenar categoriasColores después de obtener las categorías
    for (var categoria in categoriasDisponibles) {
      categoriasColores[categoria.Nombre] =
          Color(int.parse("0xFF${categoria.Color}"));
    }

    obtenerNombresCategorias();

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
      if (categoriaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una categoría')),
        );
        return;
      }

      idCategoriaSeleccionada = categoriasDisponibles
          .firstWhere((categoria) => categoria.Nombre == categoriaSeleccionada)
          .Id;

      // Si es un evento de todo el día, ajustamos las horas de las fechas
      if (eventoRecurrente) {
        fechaInicio = DateTime(
            fechaInicio.year, fechaInicio.month, fechaInicio.day, 0, 0, 0);
        fechaFin =
            DateTime(fechaFin.year, fechaFin.month, fechaFin.day, 23, 59, 59);
      }

      bool resultado = await servicioEventos.registrarEvento(
        nombre,
        descripcion,
        fechaInicio,
        fechaFin,
        widget.perfil.UsuarioId,
        widget.perfil.Id,
        idCategoriaSeleccionada!,
        [1, 2],
      );

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado con éxito')),
        );
        Navigator.pop(context);
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: DropDownSearchFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Selecciona una categoría',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(
                                Icons.store,
                                color: categoriaSeleccionada == null ||
                                        categoriaSeleccionada!.isEmpty
                                    ? Colors
                                        .grey // Si no hay categoría seleccionada, el color será gris
                                    : colorSeleccionado, // Si hay categoría seleccionada, usa el color correspondiente
                              ),
                            ),
                            controller: _dropdownSearchFieldController,
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(pattern);
                          },
                          itemBuilder: (context, String suggestion) {
                            // Obtenemos el color de la categoría a partir del mapa categoriasColores
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
                          itemSeparatorBuilder: (context, index) =>
                              const Divider(),
                          suggestionsBoxDecoration:
                              const SuggestionsBoxDecoration(
                            constraints: BoxConstraints(
                              maxHeight:
                                  150, // Ajusta el tamaño de la lista de categorías
                            ),
                          ),
                          onSuggestionSelected: (String suggestion) {
                            _dropdownSearchFieldController.text = suggestion;
                            categoriaSeleccionada = suggestion;

                            // Actualiza el color del texto seleccionado y el color del contenedor
                            setState(() {
                              colorSeleccionado =
                                  categoriasColores[suggestion] ?? Colors.grey;
                              // Almacenar el id de la categoría seleccionada
                              idCategoriaSeleccionada = categoriasDisponibles
                                  .firstWhere((c) => c.Nombre == suggestion)
                                  .Id;
                            });
                          },
                          suggestionsBoxController: suggestionBoxController,
                          validator: (value) => value!.isEmpty
                              ? 'Por favor selecciona una categoría'
                              : null,
                          displayAllSuggestionWhenTap: true,
                        ),
                      ),

                      const SizedBox(height: 16),
                      Container(
                        width: double
                            .infinity, // Esto asegura que ocupe todo el ancho posible
                        decoration: BoxDecoration(
                          color: Colores.fondo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            const Text(
                              'Participantes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _seleccionarParticipantes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colores.botones,
                              ),
                              child: const Text('Seleccionar Participantes',
                                  style: TextStyle(color: Colores.texto)),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: participantesSeleccionados.map((p) {
                                return Chip(
                                  label: Text(p.Nombre),
                                  onDeleted: () {
                                    setState(() {
                                      participantesSeleccionados.remove(p);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
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
            // Si es un evento de todo el día, solo seleccionamos la fecha y establecemos la hora a las 00:00
            pickedDate = DateTime(pickedDate.year, pickedDate.month,
                pickedDate.day, 0, 0, 0, 0, 0);
            // Para la fecha de fin, la ajustamos a las 23:59
            DateTime pickedEndDate = DateTime(pickedDate.year, pickedDate.month,
                pickedDate.day, 23, 59, 59, 999);
            onDateTimeChanged(pickedDate); // Llamar al inicio
            onDateTimeChanged(pickedEndDate); // Llamar al final
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
                ? "${dateTime.toLocal()}".split(' ')[0] // Solo fecha (sin hora)
                : "${"${dateTime.toLocal()}".split(' ')[0]}    ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}", // Formato de hora correcta
          ),
        ),
      ),
    );
  }
}
