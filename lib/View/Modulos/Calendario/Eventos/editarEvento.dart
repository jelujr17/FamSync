import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
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
  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  String? categoriaSeleccionada;
  late final List<Categorias> categorias;
  late final Map<String, Color> categoriasColores;
  late final List<String> nombresCategorias;
  late final List<Perfiles> participantesSeleccionados;
  late final List<Perfiles> participantesDisponibles;
  Color colorSeleccionado = Colores.principal;
  final _dropdownSearchFieldController = TextEditingController();
  int? idCategoriaSeleccionada;
  late final SuggestionsBoxController suggestionBoxController;
  bool eventoRecurrente = false;

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
    todoElDia();
  }

  Future<void> obtenerCategorias() async {
    categorias = await ServiciosCategorias()
        .getCategoriasByModulo(widget.perfil.UsuarioId, 1);
    categoriasColores = {
      for (var categoria in categorias)
        categoria.Nombre: Color(int.parse("0xFF${categoria.Color}"))
    };
    nombresCategorias = categorias.map((e) => e.Nombre).toList();
    setState(() {});
  }

  Future<void> obtenerParticipantes() async {
    participantesDisponibles =
        await ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(),
          child: AppBar(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nombreController, // Usar el controlador inicializado

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
            _buildCategoryDropDown(),
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
    );
  }

  Widget _buildCardSection(String title, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          content,
        ]),
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

  Widget _buildCategoryDropDown() {
    return DropDownSearchFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _dropdownSearchFieldController,
        decoration: InputDecoration(
          labelText: 'Selecciona una categoría',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.store,
              color: categoriaSeleccionada == null
                  ? Colors.grey
                  : colorSeleccionado),
        ),
      ),
      suggestionsCallback: getSuggestions,
      itemBuilder: (context, String suggestion) {
        Color categoriaColor = categoriasColores[suggestion] ?? Colors.grey;
        return ListTile(
          leading: CircleAvatar(backgroundColor: categoriaColor, radius: 12),
          title: Text(suggestion),
        );
      },
      itemSeparatorBuilder: (context, index) => const Divider(),
      onSuggestionSelected: (String suggestion) {
        _dropdownSearchFieldController.text = suggestion;
        categoriaSeleccionada = suggestion;
        setState(() {
          colorSeleccionado = categoriasColores[suggestion] ?? Colors.grey;
          idCategoriaSeleccionada =
              categorias.firstWhere((c) => c.Nombre == suggestion).Id;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: guardarCambios,
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
