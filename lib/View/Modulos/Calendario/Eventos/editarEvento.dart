import 'dart:io';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/components/colores.dart';

class EditarEventoPage extends StatefulWidget {
  final Eventos evento;
  final Perfiles perfil;

  const EditarEventoPage({
    super.key,
    required this.evento,
    required this.perfil,
  });

  @override
  State<EditarEventoPage> createState() => _EditarEventoPageState();
}

class _EditarEventoPageState extends State<EditarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  String? categoriaSeleccionada;
  late final List<Categorias> categoriasDisponibles;
  late final Map<String, Color> categoriasColores;
  late final List<String> nombresCategorias;
  List<Perfiles> participantesSeleccionados = [];
  List<Perfiles> participantesDisponibles = [];
  Color colorSeleccionado = Colores.principal;
  final _dropdownSearchFieldController = TextEditingController();
  int? idCategoriaSeleccionada;
  late final SuggestionsBoxController suggestionBoxController;
  bool eventoRecurrente = false;
  Categorias? categoriaEvento;

  @override
  void initState() {
    super.initState();
    obtenerCategorias();
    obtenerParticipantes();

    // Inicializar los valores con los datos del evento
    nombreController = TextEditingController(text: widget.evento.Nombre);
    descripcionController =
        TextEditingController(text: widget.evento.Descripcion);
    fechaInicio = DateTime.parse(widget.evento.FechaInicio);
    fechaFin = DateTime.parse(widget.evento.FechaFin);
    suggestionBoxController = SuggestionsBoxController();
    idCategoriaSeleccionada = widget.evento.IdCategoria;
    todoElDia();
    obtenerCategoria();
  }

  void obtenerCategoria() async {
    categoriaEvento = await ServiciosCategorias()
        .getCategoriasById(context, widget.evento.IdCategoria);
    categoriaSeleccionada = categoriaEvento!.Nombre;
    colorSeleccionado = categoriasColores[categoriaSeleccionada]!;
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
    categoriasDisponibles = await ServiciosCategorias()
        .getCategoriasByModulo(context, widget.perfil.UsuarioId, 1);
    categoriasColores = {
      for (var categoria in categoriasDisponibles)
        categoria.Nombre: Color(int.parse("0xFF${categoria.Color}"))
    };
    nombresCategorias = categoriasDisponibles.map((e) => e.Nombre).toList();
    setState(() {});
  }

  void obtenerParticipantes() async {
    participantesDisponibles =
        await ServicioPerfiles().getPerfiles(context, widget.perfil.UsuarioId);
    participantesSeleccionados = participantesDisponibles.where((participante) {
      return widget.evento.Participantes.contains(participante.Id);
    }).toList();
    setState(() {});
  }

  List<String> getSuggestions(String query) {
    return nombresCategorias
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void todoElDia() {
    if (fechaInicio.hour == 0 &&
        fechaInicio.minute == 0 &&
        fechaFin.hour == 23 &&
        fechaFin.minute == 59) {
      eventoRecurrente = true;
    }
    setState(() {});
  }

  void guardarCambios() {
    if (fechaFin.isBefore(fechaInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de fin no puede ser anterior a la fecha de inicio.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Llamada para guardar los cambios (lógica de backend)
    Navigator.pop(context, true);
  }

  Future<void> _editarEvento() async {
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
      List<int> idsParticipantes = [];
      for (int i = 0; i < participantesSeleccionados.length; i++) {
        idsParticipantes.add(participantesSeleccionados[i].Id);
      }
      bool resultado = await ServicioEventos().actualizarEvento(
        context,
        widget.evento.Id,
        nombreController.text,
        descripcionController.text,
        fechaInicio,
        fechaFin,
        widget.perfil.UsuarioId,
        widget.perfil.Id,
        idCategoriaSeleccionada!,
        idsParticipantes,
      );

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento editado con éxito')),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al editar el evento')),
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
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Editar evento",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colores.fondo,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colores.botones, Colores.botonesSecundarios],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller:
                    nombreController, // Usar el controlador inicializado

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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5, // Permite expandirse hasta 5 líneas
                minLines: 3, // Tamaño inicial de 3 líneas
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colores.fondo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropDownSearchFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      labelText: categoriaSeleccionada == null ||
                              categoriaSeleccionada!.isEmpty
                          ? 'Selecciona una categoría'
                          : categoriaSeleccionada,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.store,
                        color: categoriaSeleccionada == null ||
                                categoriaSeleccionada!.isEmpty
                            ? Colors.grey
                            : colorSeleccionado,
                      ),
                    ),
                    controller: _dropdownSearchFieldController,
                  ),
                  suggestionsCallback: (pattern) {
                    return getSuggestions(pattern);
                  },
                  itemBuilder: (context, String suggestion) {
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
                  itemSeparatorBuilder: (context, index) => const Divider(),
                  suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    constraints: BoxConstraints(
                      maxHeight:
                          150, // Ajusta el tamaño de la lista de categorías
                    ),
                  ),
                  onSuggestionSelected: (String suggestion) {
                    _dropdownSearchFieldController.text = suggestion;
                    categoriaSeleccionada = suggestion;
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
                  displayAllSuggestionWhenTap: true,
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Participantes',
                  border: OutlineInputBorder(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centra el contenido verticalmente
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Centra el contenido horizontalmente
                  children: [
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
              const SizedBox(height: 16),
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
              _buildDateSection(
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
              _buildDateSection(
                label: 'Fecha Final',
                dateTime: fechaFin,
                isAllDay: eventoRecurrente,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    if (newDate.isBefore(fechaInicio)) {
                      // Mostrar mensaje al usuario
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La fecha final no puede ser anterior a la fecha de inicio.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      fechaFin = newDate;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection({
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

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: _editarEvento,
        icon: const Icon(Icons.save, color: Colores.fondo),
        label: const Text('Guardar cambios',
            style: TextStyle(color: Colores.fondo)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.botones,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
