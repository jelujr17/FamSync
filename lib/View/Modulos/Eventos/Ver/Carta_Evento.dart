import 'dart:io';
import 'package:famsync/Model/Calendario/eventos.dart';

import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_Detalles_Evento.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaEvento extends StatefulWidget {
  final Perfiles perfil;
  final int orden;
  final Eventos evento;
  final VoidCallback onEventoEliminado; // Callback para notificar cambios
  final Function(Eventos) onEventoActualizado; // Callback que recibe una tarea

  const CartaEvento({
    super.key,
    required this.perfil,
    required this.orden,
    required this.evento,
    required this.onEventoEliminado, // Recibe el callback
    required this.onEventoActualizado, // Recibe el callback
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

  void editarTarea(BuildContext context) {}

  void asignarTarea(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Permite que el modal ocupe más espacio
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          backgroundColor: Colores.fondoAux.withOpacity(0.95),
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.8, // Ocupa el 90% de la altura de la pantalla
              child: DetallesEvento(
                evento: widget.evento,
                perfil: widget.perfil,
                onEventoEliminado: widget.onEventoEliminado,
                onEventoActualizado: (eventoActualizado) {
                  obtenerAvatares(); // Llama a obtenerAvatares
                  widget.onEventoActualizado(
                      eventoActualizado); // Llama al callback con el evento actualizado
                },
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.orden.isOdd ? Colores.fondoAux : Colores.texto,
          borderRadius: BorderRadius.circular(16),
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
                    color:
                        widget.orden.isOdd ? Colores.texto : Colores.fondoAux,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    esTodoElDia
                        ? "Todo el día"
                        : _formatearDuracion(duracionMinutos),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.orden.isEven
                          ? Colores.texto
                          : Colores.fondoAux,
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
