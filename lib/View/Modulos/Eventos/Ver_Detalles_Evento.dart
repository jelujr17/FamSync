import 'dart:io';

import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_ID/Ver_ID_Asignar.dart';
import 'package:famsync/View/Modulos/Eventos/Ver_ID/Ver_ID_Editar.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Carta_Tarea_Evento.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/Model/Calendario/Eventos.dart';
import 'package:provider/provider.dart';

class DetallesEvento extends StatefulWidget {
  final Eventos evento;
  final Perfiles perfil;
  final VoidCallback onEventoEliminado; // Callback para notificar cambios
  final Function(Eventos) onEventoActualizado; // Callback que recibe una tarea

  const DetallesEvento(
      {super.key,
      required this.evento,
      required this.perfil,
      required this.onEventoEliminado, // Recibe el callback
      required this.onEventoActualizado // Callback que recibe una tarea

      });
  @override
  State<DetallesEvento> createState() => _DetallesEventoState();
}

class _DetallesEventoState extends State<DetallesEvento> {
  List<Perfiles> perfilesDestinatarios = [];
  List<File> avatares = [];
  late Categorias categoria = Categorias(
    CategoriaID: "0",
    Color: "000000",
    nombre: "Sin categoría",
    PerfilID: "0",
  );
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      // Cargar perfiles
      await perfilesProvider.cargarPerfiles(user!.uid);
      // Cargar categorías
      await categoriasProvider.cargarCategorias(
          user!.uid, widget.perfil.PerfilID);

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
          .firstWhere((cat) => cat.CategoriaID == widget.evento.CategoriaID);
      return categoria.nombre;
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
          .firstWhere((cat) => cat.CategoriaID == widget.evento.CategoriaID);
      print("Categoría obtenida: ${categoria.nombre}");
    } catch (e) {
      categoria = Categorias(
        CategoriaID: "0",
        Color: "030303",
        nombre: "Sin categoría",
        PerfilID: "0",
      );
      print("Error al obtener la categoría: $e");
    }
  }

  void obtenerAvatares() async {
    try {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);

      // Filtrar los perfiles destinatarios
      perfilesDestinatarios = perfilesProvider.perfiles
          .where(
              (perfil) => widget.evento.participantes.contains(perfil.PerfilID))
          .toList();

      print(
          "Perfiles destinatarios: ${perfilesDestinatarios.map((p) => p.PerfilID)}");

      // Cargar las imágenes de los perfiles
      final imagenesCargadas = await Future.wait(
        perfilesDestinatarios.map(
          (perfil) async {
            try {
              final imagen = await ServicioPerfiles()
                  .getFotoPerfil(user!.uid, perfil.PerfilID);
              print("Imagen cargada para perfil ${perfil.PerfilID}: $imagen");
              return imagen;
            } catch (e) {
              print(
                  "Error al cargar imagen para perfil ${perfil.PerfilID}: $e");
              return null; // Devuelve null si falla
            }
          },
        ),
      );

      if (mounted) {
        setState(() {
          avatares =
              imagenesCargadas.whereType<File>().toList(); // Filtra los nulos
        });
      }
    } catch (e) {
      print('Error al cargar avatares: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventoProvider = Provider.of<EventosProvider>(context);
    final eventoActualizado = eventoProvider.eventos.firstWhere(
      (e) => e.EventoID == widget.evento.EventoID,
      orElse: () => widget.evento, // Usa el evento original si no se encuentra
    );

    final DateTime fechaInicio = eventoActualizado.fechaInicio.toDate();
    final DateTime fechaFin = eventoActualizado.fechaFin.toDate();
    final bool esTodoElDia = fechaInicio.hour == 0 &&
        fechaInicio.minute == 0 &&
        fechaFin.hour == 23 &&
        fechaFin.minute == 59 &&
        fechaInicio.year == fechaFin.year &&
        fechaInicio.month == fechaFin.month &&
        fechaInicio.day == fechaFin.day;
    final tareasProvider = Provider.of<TareasProvider>(context, listen: false);

    final tarea = tareasProvider.tareas;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con color de categoría y opciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colores.texto,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detalles del Evento",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colores.fondoAux,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Editar') {
                        editarEvento(context);
                      } else if (result == 'Asignar') {
                        asignarEvento(context);
                      } else if (result == 'Eliminar') {
                        eliminarEvento(context);
                        Navigator.of(context).pop(); // Cerrar el diálogo
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Asignar',
                        child: Container(
                          constraints: const BoxConstraints(
                              maxWidth: 200), // Limita el ancho
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ajusta el tamaño al contenido
                            children: [
                              Icon(Icons.person_add, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Asignar a Otro Usuario',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'Editar',
                        child: Container(
                          constraints: const BoxConstraints(
                              maxWidth: 200), // Limita el ancho
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ajusta el tamaño al contenido
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colores.texto,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colores.texto,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'Eliminar',
                        child: Container(
                          constraints: const BoxConstraints(
                              maxWidth: 200), // Limita el ancho
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ajusta el tamaño al contenido
                            children: [
                              const Icon(Icons.delete, color: Colores.eliminar),
                              const SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colores.eliminar,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      color: Colores.fondoAux,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Bordes redondeados
                    ),
                    color: Colores.fondoAux, // Color de fondo del menú
                    constraints: const BoxConstraints(
                      maxHeight: 200, // Altura máxima del menú
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // nombre del evento
            _buildEventName(eventoActualizado.nombre),
            const SizedBox(height: 16),

            // Descripción del evento
            _buildEventDescription(eventoActualizado.descripcion),
            const SizedBox(height: 16),

            // Categoría del evento
            _buildEventCategoria(categoria),
            const SizedBox(height: 16),
            if (esTodoElDia) _buildTodoDia(),
            // Horas (Inicio y Fin)
            if (!esTodoElDia)
              Row(
                children: [
                  Expanded(
                    child: _buildEventHora(
                      icon: Icons.calendar_today,
                      titulo: "Inicio",
                      hora: _formatearHora(
                          eventoActualizado.fechaInicio.toDate()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEventHora(
                      icon: Icons.access_time,
                      titulo: "Fin",
                      hora: _formatearHora(eventoActualizado.fechaFin.toDate()),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // participantes con avatares
            _buildParticipantsSection(),

            const SizedBox(height: 16),
            if (eventoActualizado.TareaID != null)
              Row(
                children: [
                  Icon(Icons.task, color: Colores.texto),
                  const SizedBox(width: 8),
                  Text(
                    "Tarea Asociada:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colores.texto,
                    ),
                  ),
                ],
              ),
            if (eventoActualizado.TareaID != null)
              CartaTareaEvento(
                perfil: widget.perfil,
                orden: 1,
                tarea: tarea.firstWhere(
                  (t) => t.TareaID == eventoActualizado.TareaID,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método para construir la sección de participantes con avatares
  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: Colores.texto),
            const SizedBox(width: 8),
            Text(
              "participantes:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colores.texto,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEventPerfiles(),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatearHora(DateTime fecha) {
    return "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEventName(String nombre) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.texto.withOpacity(0.1), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.texto.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Colores.texto, size: 24), // Icono del evento
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colores.texto,
              ),
              overflow: TextOverflow.ellipsis, // Manejo de texto largo
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription(String descripcion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.texto.withOpacity(0.05), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.texto.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description, color: Colores.texto, size: 24), // Icono
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descripcion.isNotEmpty ? descripcion : "Sin descripción",
              style: TextStyle(
                fontSize: 14,
                color: Colores.texto,
              ),
              textAlign: TextAlign.justify, // Justifica el texto
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCategoria(Categorias categoria) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(int.parse("0xFF${categoria.Color}"))
            .withOpacity(0.2), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(int.parse("0xFF${categoria.Color}")).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.category, color: Colores.texto, size: 24), // Icono
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              categoria.nombre,
              style: TextStyle(
                fontSize: 14,
                color: Colores.texto,
              ),
              textAlign: TextAlign.justify, // Justifica el texto
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventPerfiles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.fondo.withOpacity(0.2), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colores.fondo.withOpacity(0.3),
        ),
      ),
      child: Wrap(
        spacing: 8,
        children: perfilesDestinatarios.map((perfil) {
          int idx = perfilesDestinatarios.indexOf(perfil);
          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    avatares.length > idx ? FileImage(avatares[idx]) : null,
                child: avatares.length <= idx
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                perfil.nombre,
                style: TextStyle(
                  fontSize: 12,
                  color: Colores.texto,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventHora(
      {required IconData icon, required String titulo, required String hora}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.texto.withOpacity(0.05), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.texto.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colores.texto, size: 24), // Icono representativo
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colores.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hora,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colores.texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoDia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.texto.withOpacity(0.05), // Fondo sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.texto.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time,
              color: Colores.texto, size: 24), // Icono representativo
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Todo el Día",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colores.texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void eliminarEvento(BuildContext context) {
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
                    'Eliminar evento',
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
                    '¿Estás seguro de que deseas eliminar el evento ${widget.evento.nombre}?',
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
                            .eliminarEvento(user!.uid, widget.evento.EventoID);
                        if (exito) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final eventoProvider = Provider.of<EventosProvider>(
                                context,
                                listen: false);
                            eventoProvider
                                .eliminarEvento(widget.evento.EventoID);
                          });
                          Navigator.of(context).pop(); // Cerrar el diálogo

                          widget.onEventoEliminado(); // Notificar cambios
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al eliminar la tarea.'),
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

  void asignarEvento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AsignarEventoDialog(
          evento: widget.evento,
          perfil: widget.perfil,
          context: context,
          onAsignarGuardado: (asignacion) async {
            print("Asignación recibida: $asignacion");
            final nuevoEvento = Eventos(
              EventoID: widget.evento.EventoID,
              nombre: widget.evento.nombre,
              descripcion: widget.evento.descripcion,
              PerfilID: widget.evento.PerfilID,
              participantes: asignacion,
              CategoriaID: widget.evento.CategoriaID,
              fechaInicio: widget.evento.fechaInicio,
              fechaFin: widget.evento.fechaFin,
              TareaID: widget.evento.TareaID,
            );

            final exito = await ServicioEventos().actualizarEvento(
              user!.uid,
              nuevoEvento.EventoID,
              nuevoEvento.nombre,
              nuevoEvento.descripcion,
              nuevoEvento.fechaInicio,
              nuevoEvento.fechaFin,
              nuevoEvento.PerfilID,
              nuevoEvento.CategoriaID,
              nuevoEvento.participantes,
              nuevoEvento.TareaID,
            );

            if (exito) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final eventosProvider =
                    Provider.of<EventosProvider>(context, listen: false);
                eventosProvider.actualizarEvento(nuevoEvento);
                Navigator.of(context).pop();
              });
              obtenerAvatares();
              widget.onEventoActualizado(nuevoEvento); // Notificar cambios
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al actualizar la tarea.'),
                ),
              );
            }
          },
        );
      },
    );
  }

  void editarEvento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return EditarEventoDialog(
              evento: widget.evento,
              context: context,
              perfil: widget.perfil,
              onEventoEditado: (nombre, descripcion, categoria, fechaInicio,
                  fechaFin) async {
                final nuevoEvento = Eventos(
                  EventoID: widget.evento.EventoID,
                  nombre: widget.evento.nombre,
                  descripcion: widget.evento.descripcion,
                  PerfilID: widget.evento.PerfilID,
                  participantes: widget.evento.participantes,
                  CategoriaID: widget.evento.CategoriaID,
                  fechaInicio: widget.evento.fechaInicio,
                  fechaFin: widget.evento.fechaFin,
                  TareaID: widget.evento.TareaID,
                );

                final exito = await ServicioEventos().actualizarEvento(
                  user!.uid,
                  nuevoEvento.EventoID,
                  nuevoEvento.nombre,
                  nuevoEvento.descripcion,
                  nuevoEvento.fechaInicio,
                  nuevoEvento.fechaFin,
                  nuevoEvento.PerfilID,
                  nuevoEvento.CategoriaID,
                  nuevoEvento.participantes,
                  nuevoEvento.TareaID,
                );

                if (exito) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final eventosProvider =
                        Provider.of<EventosProvider>(context, listen: false);
                    eventosProvider.actualizarEvento(nuevoEvento);
                    Navigator.of(context).pop();
                  });
                  obtenerCategoria();
                  widget.onEventoActualizado(nuevoEvento); // Notificar cambios
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al editar el evento.'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
