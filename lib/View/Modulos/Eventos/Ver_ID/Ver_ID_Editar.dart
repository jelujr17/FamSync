import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_ID/Editar_ID_Categoria.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_ID/Editar_ID_Fechas.dart';
import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';
import 'package:provider/provider.dart';

class EditarEventoDialog extends StatefulWidget {
  final Eventos evento;
  final Function(String, String, int?, String, String) onEventoEditado;
  final BuildContext context;
  final Perfiles perfil;

  const EditarEventoDialog({
    super.key,
    required this.evento,
    required this.onEventoEditado,
    required this.context,
    required this.perfil,
  });

  @override
  _EditarEventoDialogState createState() => _EditarEventoDialogState();
}

class _EditarEventoDialogState extends State<EditarEventoDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  List<String> nombresCategoria = [];
  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now();
  bool esTodoElDia = false;
  TimeOfDay horaInicio = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 0, minute: 0);
  DateTime fecha = DateTime.now();

  @override
  void initState() {
    nombreController.text = widget.evento.Nombre;
    descripcionController.text = widget.evento.Descripcion;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(context, widget.perfil.UsuarioId, 5);
    });
    super.initState();
    fechaInicio = DateTime.parse(widget.evento.FechaInicio);
    fechaFin = DateTime.parse(widget.evento.FechaFin);
    horaInicio = TimeOfDay(hour: fechaInicio.hour, minute: fechaInicio.minute);
    horaFin = TimeOfDay(hour: fechaFin.hour, minute: fechaFin.minute);
    fecha = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
    esTodoElDia = fechaInicio.hour == 0 &&
        fechaInicio.minute == 0 &&
        fechaFin.hour == 23 &&
        fechaFin.minute == 59 &&
        fechaInicio.year == fechaFin.year &&
        fechaInicio.month == fechaFin.month &&
        fechaInicio.day == fechaFin.day;
  }

  @override
  Widget build(context) {
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasDisponibles = categoriasProvider.categorias;
    nombresCategoria = categoriasDisponibles.map((e) => e.Nombre).toList();
    categoriaSeleccionada = categoriasDisponibles
        .firstWhere((element) => element.Id == widget.evento.IdCategoria,
            orElse: () => Categorias(
                Id: 0,
                Nombre: "Sin Categoría",
                IdModulo: 0,
                Color: '000000',
                IdUsuario: 0))
        .Nombre;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colores.fondo.withOpacity(0.95), // Fondo del diálogo
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colores.texto.withOpacity(0.3),
                offset: const Offset(0, 30),
                blurRadius: 60,
              ),
              const BoxShadow(
                color: Colores.texto,
                offset: Offset(0, 30),
                blurRadius: 60,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título del diálogo
                    Text(
                      'Editar Evento',
                      style: TextStyle(
                        color: Colores.texto,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo para el nombre de la tarea
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Evento',
                        labelStyle:
                            const TextStyle(fontSize: 16, color: Colores.texto),
                        hintText: 'Ingresa un nombre para la Tarea',
                        hintStyle: const TextStyle(color: Colores.texto),
                        prefixIcon: const Icon(Icons.shopping_bag,
                            color: Colores.texto),
                        filled: true,
                        fillColor: Colores.fondoAux,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none, // Sin borde inicial
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colores.fondoAux, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colores.texto, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                      ),
                      style: const TextStyle(
                          color:
                              Colores.texto), // Cambia el color del texto aquí
                    ),
                    const SizedBox(height: 16),

                    // Campo para la descripción de la tarea
                    TextFormField(
                      controller: descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción del Evento',
                        labelStyle:
                            const TextStyle(fontSize: 16, color: Colores.texto),
                        hintText: 'Ingresa una descripción para la Tarea',
                        hintStyle: const TextStyle(color: Colores.texto),
                        prefixIcon:
                            const Icon(Icons.description, color: Colores.texto),
                        filled: true,
                        fillColor: Colores.fondoAux,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none, // Sin borde inicial
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colores.fondoAux, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colores.texto, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                      ),
                      style: const TextStyle(
                        color: Colores.texto, // Cambia el color del texto aquí
                      ),
                      maxLines: 5, // Permite que el campo tenga hasta 5 líneas
                      minLines: 3, // Mínimo de 3 líneas para que sea más grande
                      keyboardType: TextInputType
                          .multiline, // Permite entrada de texto multilinea
                    ),
                    const SizedBox(height: 16),
                    CampoCategoriaEditarEvento(
                      categoriaSeleccionada: categoriaSeleccionada,
                      categoriasDisponibles: nombresCategoria,
                      categorias: categoriasDisponibles,
                      onCategoriaSeleccionada: (String? categoria) {
                        if (categoria == "Sin Categoría") {
                          categoria = null;
                        }
                        categoriaSeleccionada = categoria;
                      },
                    ),
                    const SizedBox(height: 16),
                    CampoFechasEditarEvento(
                      fecha: DateTime(
                          fechaInicio.year, fechaInicio.month, fechaInicio.day),
                      horaInicio: horaInicio,
                      horaFin: horaFin,
                      todoElDia: esTodoElDia,
                      onFechaChanged: (value) {
                        setState(() {
                          fecha = value!;
                          fechaInicio = DateTime(value.year, value.month,
                              value.day, horaInicio.hour, horaInicio.minute);
                          fechaFin = DateTime(value.year, value.month,
                              value.day, horaFin.hour, horaFin.minute);
                        });
                      },
                      onHoraInicioChanged: (value) {
                        setState(() {
                          horaInicio = value!;
                          fechaInicio = DateTime(fecha.year, fecha.month,
                              fecha.day, horaInicio.hour, horaInicio.minute);
                        });
                      },
                      onHoraFinChanged: (value) {
                        setState(() {
                          horaFin = value!;
                          fechaFin = DateTime(fecha.year, fecha.month,
                              fecha.day, horaFin.hour, horaFin.minute);
                        });
                      },
                      onTodoElDiaChanged: (value) {
                        setState(() {
                          esTodoElDia = value;
                          if (esTodoElDia) {
                            horaInicio = const TimeOfDay(hour: 0, minute: 0);
                            horaFin = const TimeOfDay(hour: 23, minute: 59);
                          }
                        });
                      },
                      validatorFecha: (fecha) {
                        if (fecha == null) return 'Selecciona la fecha';
                        return null;
                      },
                      validatorHoraInicio: (hora) {
                        if (!esTodoElDia && hora == null) {
                          return 'Selecciona la hora de inicio';
                        }
                        return null;
                      },
                      validatorHoraFin: (hora) {
                        if (!esTodoElDia && hora == null) {
                          return 'Selecciona la hora de fin';
                        }
                        return null;
                      },
                    ),
                    // Botones para guardar o cancelar
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(this.context)
                                .pop(); // Cerrar el diálogo
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colores.fondoAux,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                              int? categoriaAux = categoriasDisponibles
                                  .firstWhere(
                                    (element) =>
                                        element.Nombre == categoriaSeleccionada,
                                   
                                  )
                                  .Id;
                              if (categoriaAux == 0) {
                                categoriaAux = null;
                              }
                              widget.onEventoEditado(
                                  nombreController.text,
                                  descripcionController.text,
                                  categoriaAux,
                                  fechaInicio.toString(),
                                  fechaFin.toString());
                          },
                          child: Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colores.texto,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
