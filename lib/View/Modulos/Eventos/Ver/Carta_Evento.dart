import 'dart:io';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';

import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaEvento extends StatefulWidget {
  final Perfiles perfil;
  final int orden;
  final Eventos evento;
  final VoidCallback onTareaEliminada; // Callback para notificar cambios
  final Function(Eventos) onTareaDuplicada; // Callback que recibe una tarea
  final Function(Eventos) onTareaActualizada; // Callback que recibe una tarea

  const CartaEvento({
    super.key,
    required this.perfil,
    required this.orden,
    required this.evento,
    required this.onTareaEliminada, // Recibe el callback
    required this.onTareaDuplicada, // Recibe el callback
    required this.onTareaActualizada, // Recibe el callback
  });

  @override
  State<CartaEvento> createState() => CartaEventoState();
}

class CartaEventoState extends State<CartaEvento> {
  List<Perfiles> perfilesDestinatarios = [];
  List<File> avatares = [];
  late Categorias categoria = Categorias(
    Id: 0,
    Nombre: "Sin categoría",
    Color: widget.orden.isEven ? "7A7F84" : "EDEDED",
    IdModulo: 0,
    IdUsuario: 0,
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      // Cargar perfiles
      await perfilesProvider.cargarPerfiles(context, widget.perfil.UsuarioId);
      // Cargar categorías
      await categoriasProvider.cargarCategorias(
          context, widget.perfil.UsuarioId, 1);

      // Llamar a obtenerAvatares después de cargar los perfiles
      obtenerAvatares();
      obtenerCategoria();
    });
  }

  Future<String?> obtenerCategoriaNombre() async {
    try {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      final categoria = categoriasProvider.categorias
          .firstWhere((cat) => cat.Id == widget.evento.IdCategoria);
      return categoria.Nombre;
    } catch (e) {
      print("Error al obtener la categoría: $e");
      return null;
    }
  }

  void obtenerCategoria() async {
    try {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoria = categoriasProvider.categorias
          .firstWhere((cat) => cat.Id == widget.evento.IdCategoria);
      print("Categoría obtenida: ${categoria.Nombre}");
    } catch (e) {
      categoria = Categorias(
        Id: 0,
        Nombre: "Sin categoría",
        Color: widget.orden.isEven ? "7A7F84" : "EDEDED",
        IdModulo: 0,
        IdUsuario: 0,
      );
      print("Error al obtener la categoría: $e");
    }
  }

  void obtenerAvatares() async {
    try {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);

      // Filtrar los perfiles destinatarios
      final List<Perfiles> destinatarios = perfilesProvider.perfiles
          .where((perfil) => widget.evento.Participantes.contains(perfil.Id))
          .toList();

      print("Perfiles destinatarios: ${destinatarios.map((p) => p.Id)}");

      // Cargar las imágenes de los perfiles
      final List<File?> imagenesCargadas = await Future.wait(
        destinatarios.map((perfil) async {
          try {
            return await ServicioPerfiles()
                .obtenerImagen(context, perfil.FotoPerfil);
          } catch (e) {
            print("Error al cargar imagen para perfil ${perfil.Id}: $e");
            return null; // Devuelve null si falla
          }
        }),
      );

      // Actualizar el estado con los perfiles y las imágenes cargadas
      if (mounted) {
        setState(() {
          perfilesDestinatarios = destinatarios;
          avatares =
              imagenesCargadas.whereType<File>().toList(); // Filtra los nulos
        });
      }
    } catch (e) {
      print('Error al cargar avatares: $e');
    }
  }

  void eliminartarea(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bordes redondeados
          ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Eliminar tarea',
                    style: TextStyle(
                      color: Colores.texto,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '¿Estás seguro de que deseas eliminar el evento ${widget.evento.Nombre}?',
                    style: TextStyle(
                      color: Colores.texto,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colores.texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Lógica para eliminar la tarea
                        final exito = await ServicioEventos()
                            .eliminarEvento(context, widget.evento.Id);
                        if (exito) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final eventoProvider = Provider.of<EventosProvider>(
                                context,
                                listen: false);
                            eventoProvider.eliminarEvento(widget.evento.Id);
                          });
                          Navigator.of(context).pop(); // Cerrar el diálogo

                          widget.onTareaEliminada(); // Notificar cambios
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al eliminar el evento.'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colores.eliminar,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void editarTarea(BuildContext context) {}

  void asignarTarea(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    // Parsear las fechas de inicio y fin
    final DateTime fechaInicio = DateTime.parse(widget.evento.FechaInicio);
    final DateTime fechaFin = DateTime.parse(widget.evento.FechaFin);

    // Determinar si el evento dura todo el día
    final bool esTodoElDia = fechaInicio.hour == 0 &&
        fechaInicio.minute == 0 &&
        fechaFin.hour == 23 &&
        fechaFin.minute == 59 &&
        fechaInicio.year == fechaFin.year &&
        fechaInicio.month == fechaFin.month &&
        fechaInicio.day == fechaFin.day;

    // Calcular la duración del evento en minutos
    final int duracionMinutos = fechaFin.difference(fechaInicio).inMinutes;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Espaciado externo
      padding: const EdgeInsets.all(16), // Espaciado interno
      decoration: BoxDecoration(
        color: widget.orden.isOdd
            ? Colores.fondoAux
            : Colores.texto, // Color de fondo
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: widget.orden.isEven ? Colores.fondoAux : Colores.fondo,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del evento y avatares
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título del evento
              Expanded(
                child: Text(
                  widget.evento.Nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.orden.isOdd ? Colores.texto : Colores.fondoAux,
                  ),
                ),
              ),
              // Avatares de los participantes
              Row(
                children: perfilesDestinatarios.map((perfil) {
                  int idx = perfilesDestinatarios.indexOf(perfil);
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: FileImage(avatares[idx]),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 40, // Ajusta el ancho según lo que necesites
                          child: Text(
                            perfil.Nombre,
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.orden.isOdd
                                  ? Colores.texto
                                  : Colores.fondoAux,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hora de inicio, duración y hora de fin
          Row(
            mainAxisAlignment: esTodoElDia
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!esTodoElDia)
                // Hora de inicio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatearHora(fechaInicio),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.orden.isOdd
                            ? Colores.texto
                            : Colores.fondoAux,
                      ),
                    ),
                    Text(
                      "Inicio",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.orden.isOdd
                            ? Colores.texto
                            : Colores.fondoAux,
                      ),
                    ),
                  ],
                ),
              // Duración o "Todo el día"
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
                decoration: BoxDecoration(
                  color: widget.orden.isOdd ? Colores.texto : Colores.fondoAux,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  esTodoElDia
                      ? "Todo el día"
                      : _formatearDuracion(duracionMinutos),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                  ),
                ),
              ),
              if (!esTodoElDia)
                // Hora de fin
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatearHora(fechaFin),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.orden.isOdd
                            ? Colores.texto
                            : Colores.fondoAux,
                      ),
                    ),
                    Text(
                      "Fin",
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.orden.isOdd
                            ? Colores.texto
                            : Colores.fondoAux,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Función para formatear horas
  String _formatearHora(DateTime fecha) {
    return "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  // Agrega esta función en tu clase CartaEventoState:
  String _formatearDuracion(int minutos) {
    if (minutos < 60) {
      return "$minutos min";
    } else {
      final horas = minutos ~/ 60;
      final min = minutos % 60;
      if (min == 0) {
        return "$horas h";
      }
      return "$horas h $min min";
    }
  }
}
