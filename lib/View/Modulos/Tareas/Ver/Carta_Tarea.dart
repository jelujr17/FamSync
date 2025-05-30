import 'dart:io';
import 'package:famsync/View/Modulos/Eventos/Crear_Evento_Tarea.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Ver_ID_Asignar.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Ver_ID_Progresar.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Ver_ID_Editar.dart';

import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaTarea extends StatefulWidget {
  final Perfiles perfil;
  final int orden;
  final Tareas tarea;
  final String filtro;
  final VoidCallback onTareaEliminada; // Callback para notificar cambios
  final Function(Tareas) onTareaDuplicada; // Callback que recibe una tarea
  final Function(Tareas) onTareaActualizada; // Callback que recibe una tarea

  const CartaTarea({
    super.key,
    required this.perfil,
    required this.orden,
    required this.tarea,
    required this.filtro,
    required this.onTareaEliminada, // Recibe el callback
    required this.onTareaDuplicada, // Recibe el callback
    required this.onTareaActualizada, // Recibe el callback
  });

  @override
  State<CartaTarea> createState() => CartaTareaState();
}

class CartaTareaState extends State<CartaTarea> {
  final user = FirebaseAuth.instance.currentUser;

  List<Perfiles> perfilesDestinatarios = [];
  List<File> avatares = [];
  late Categorias categoria = Categorias(
    CategoriaID: "0",
    Color: widget.orden.isEven ? "FFDB89" : "030303",
    nombre: "Sin categoría",
    PerfilID: "0",
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
          .firstWhere((cat) => cat.CategoriaID == widget.tarea.CategoriaID);
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
          .firstWhere((cat) => cat.CategoriaID == widget.tarea.CategoriaID);
      print("Categoría obtenida: ${categoria.nombre}");
    } catch (e) {
      categoria = Categorias(
        CategoriaID: "0",
        Color: widget.orden.isEven ? "FFDB89" : "030303",
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
              (perfil) => widget.tarea.destinatario.contains(perfil.PerfilID))
          .toList();

      print(
          "Perfiles destinatarios: ${perfilesDestinatarios.map((p) => p.PerfilID)}");

      // Cargar las imágenes de los perfiles
      final imagenesCargadas = await Future.wait(
        perfilesDestinatarios.map(
          (perfil) async {
            try {
              final imagen = await ServicioPerfiles()
                  .getFotoPerfil(user!.uid, perfil.FotoPerfil);
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

  Color getContrastingTextColor(Color color) {
    // Calcula el brillo del color
    final double brightness =
        (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;

    // Si el brillo es alto, usa un color oscuro; de lo contrario, usa un color claro
    return brightness > 0.5 ? Colors.black : Colors.white;
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
                    '¿Estás seguro de que deseas eliminar la tarea ${widget.tarea.nombre}?',
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
                        final exito = await ServicioTareas()
                            .eliminarTarea(user!.uid, widget.tarea.TareaID);
                        if (exito) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final tareaProvider = Provider.of<TareasProvider>(
                                context,
                                listen: false);
                            tareaProvider.eliminarTarea(widget.tarea.TareaID);
                          });
                          Navigator.of(context).pop(); // Cerrar el diálogo

                          widget.onTareaEliminada(); // Notificar cambios
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

  void asigarEvento(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CrearEventoTarea(perfil: widget.perfil, tarea: widget.tarea),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Se realizó una actualización
    }
  }

  void duplicarTarea(BuildContext context) {
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
                    'Duplicar tarea',
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
                    '¿Estás seguro de que deseas duplicar la tarea "${widget.tarea.nombre}"?',
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
                        // Lógica para duplicar la tarea
                        final nuevaTarea = Tareas(
                          TareaID: widget.tarea.TareaID,
                          nombre: "${widget.tarea.nombre} (Copia)",
                          descripcion: widget.tarea.descripcion,
                          creador: widget.tarea.creador,
                          destinatario: widget.tarea.destinatario,
                          CategoriaID: widget.tarea.CategoriaID,
                          EventoID: widget.tarea.EventoID,
                          prioridad: widget.tarea.prioridad,
                          progreso:
                              widget.tarea.progreso, // Reinicia el progreso
                        );

                        final exito = await ServicioTareas().registrarTarea(
                            user!.uid,
                            nuevaTarea.creador,
                            nuevaTarea.destinatario,
                            nuevaTarea.nombre,
                            nuevaTarea.descripcion,
                            nuevaTarea.EventoID,
                            nuevaTarea.CategoriaID,
                            nuevaTarea.prioridad,
                            nuevaTarea.progreso);

                        if (exito) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final tareaProvider = Provider.of<TareasProvider>(
                                context,
                                listen: false);
                            tareaProvider.agragarTarea(nuevaTarea);
                            Navigator.of(context).pop();
                          });
                          widget.onTareaDuplicada(
                              nuevaTarea); // Notificar cambios
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al duplicar la tarea.'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Duplicar',
                        style: TextStyle(
                          color: Colores.principal,
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

  void progresarTarea(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ProgresarTareaDialog(
          tarea: widget.tarea,
          context: context,
          onProgresoGuardado: (nuevoProgreso) async {
            final nuevaTarea = Tareas(
              TareaID: widget.tarea.TareaID,
              nombre: widget.tarea.nombre,
              descripcion: widget.tarea.descripcion,
              creador: widget.tarea.creador,
              destinatario: widget.tarea.destinatario,
              CategoriaID: widget.tarea.CategoriaID,
              EventoID: widget.tarea.EventoID,
              prioridad: widget.tarea.prioridad,
              progreso: nuevoProgreso, // Reinicia el progreso
            );

            final exito = await ServicioTareas().actualizarTarea(
                user!.uid,
                nuevaTarea.TareaID,
                nuevaTarea.creador,
                nuevaTarea.destinatario,
                nuevaTarea.nombre,
                nuevaTarea.descripcion,
                nuevaTarea.EventoID,
                nuevaTarea.CategoriaID,
                nuevaTarea.prioridad,
                nuevaTarea.progreso);

            if (exito) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final tareaProvider =
                    Provider.of<TareasProvider>(context, listen: false);
                tareaProvider.actualizarTarea(nuevaTarea);
                Navigator.of(context).pop();
              });
              widget.onTareaActualizada(nuevaTarea); // Notificar cambios
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

  void editarTarea(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EditarTareaDialog(
          tarea: widget.tarea,
          context: context,
          perfil: widget.perfil,
          onTareaEditada: (nombre, descripcion, categoria, prioridad) async {
            final nuevaTarea = Tareas(
              TareaID: widget.tarea.TareaID,
              nombre: nombre,
              descripcion: descripcion,
              creador: widget.tarea.creador,
              destinatario: widget.tarea.destinatario,
              CategoriaID: categoria,
              EventoID: widget.tarea.EventoID,
              prioridad: prioridad,
              progreso: widget.tarea.progreso, // Reinicia el progreso
            );

            final exito = await ServicioTareas().actualizarTarea(
                user!.uid,
                nuevaTarea.TareaID,
                nuevaTarea.creador,
                nuevaTarea.destinatario,
                nuevaTarea.nombre,
                nuevaTarea.descripcion,
                nuevaTarea.EventoID,
                nuevaTarea.CategoriaID,
                nuevaTarea.prioridad,
                nuevaTarea.progreso);

            if (exito) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final tareaProvider =
                    Provider.of<TareasProvider>(context, listen: false);
                tareaProvider.actualizarTarea(nuevaTarea);
                Navigator.of(context).pop();
              });
              widget.onTareaActualizada(nuevaTarea); // Notificar cambios
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al editar la tarea.'),
                ),
              );
            }
          },
        );
      },
    );
  }

  void asignarTarea(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AsignarTareaDialog(
          tarea: widget.tarea,
          perfil: widget.perfil,
          context: context,
          onAsignarGuardado: (asignacion) async {
            print("Asignación recibida: $asignacion");
            final nuevaTarea = Tareas(
              TareaID: widget.tarea.TareaID,
              nombre: widget.tarea.nombre,
              descripcion: widget.tarea.descripcion,
              creador: widget.tarea.creador,
              destinatario: asignacion,
              CategoriaID: widget.tarea.CategoriaID,
              EventoID: widget.tarea.EventoID,
              prioridad: widget.tarea.prioridad,
              progreso: widget.tarea.progreso, // Reinicia el progreso
            );

            final exito = await ServicioTareas().actualizarTarea(
                user!.uid,
                nuevaTarea.TareaID,
                nuevaTarea.creador,
                nuevaTarea.destinatario,
                nuevaTarea.nombre,
                nuevaTarea.descripcion,
                nuevaTarea.EventoID,
                nuevaTarea.CategoriaID,
                nuevaTarea.prioridad,
                nuevaTarea.progreso);

            if (exito) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final tareaProvider =
                    Provider.of<TareasProvider>(context, listen: false);
                tareaProvider.actualizarTarea(nuevaTarea);
                Navigator.of(context).pop();
              });
              obtenerAvatares();
              widget.onTareaActualizada(nuevaTarea); // Notificar cambios
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Espaciado externo
      decoration: BoxDecoration(
        color: widget.orden.isEven ? Colores.fondoAux : Colores.texto,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.orden.isEven
                ? Colores.texto.withOpacity(0.5)
                : Colores.fondoAux.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e ícono de opciones
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.tarea.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.orden.isEven ? Colores.texto : Colores.fondo,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'Editar') {
                      editarTarea(context);
                    } else if (result == 'Progresar') {
                      progresarTarea(context);
                    } else if (result == 'Asignar') {
                      asignarTarea(context);
                    } else if (result == 'Duplicar') {
                      duplicarTarea(context);
                    } else if (result == 'Eliminar') {
                      eliminartarea(context);
                    } else if (result == 'Añadir') {
                      asigarEvento(context);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Progresar',
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: 200), // Limita el ancho
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
                          children: [
                            Icon(Icons.check_circle, color: Colores.hecho),
                            const SizedBox(width: 8),
                            Text(
                              'Progresar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colores.hecho,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'Duplicar',
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: 200), // Limita el ancho
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
                          children: [
                            Icon(Icons.copy, color: Colores.principal),
                            const SizedBox(width: 8),
                            Text(
                              'Duplicar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colores.principal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'Asignar',
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: 200), // Limita el ancho
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
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
                      value: 'Añadir',
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: 200), // Limita el ancho
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
                          children: [
                            Icon(Icons.calendar_today, color: Colors.purple),
                            const SizedBox(width: 8),
                            Text(
                              'Añadir al calendario',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'Asignar',
                      child: Container(
                        constraints: const BoxConstraints(
                            maxWidth: 200), // Limita el ancho
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
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
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
                          children: [
                            Icon(
                              Icons.edit,
                              color: widget.orden.isEven
                                  ? Colores.fondoAux
                                  : Colores.texto,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.orden.isEven
                                    ? Colores.fondoAux
                                    : Colores.texto,
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
                          mainAxisSize:
                              MainAxisSize.min, // Ajusta el tamaño al contenido
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
                    color:
                        widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16), // Bordes redondeados
                  ),
                  color: widget.orden.isEven
                      ? Colores.texto
                      : Colores.fondoAux, // Color de fondo del menú
                  constraints: const BoxConstraints(
                    maxHeight: 200, // Altura máxima del menú
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // prioridad
          Container(
            constraints: const BoxConstraints(
                minWidth: 150), // Ancho mínimo para consistencia
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: widget.tarea.prioridad == 1 || widget.tarea.progreso == 100
                  ? Colores.hecho.withOpacity(0.2)
                  : widget.tarea.prioridad == 2
                      ? Colores.naranja.withOpacity(0.2)
                      : Colores.eliminar.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.tarea.progreso == 100
                      ? Icons.check_circle
                      : widget.tarea.prioridad == 1
                          ? Icons.start
                          : widget.tarea.prioridad == 2
                              ? Icons.warning
                              : Icons.error,
                  color: widget.tarea.prioridad == 1 ||
                          widget.tarea.progreso == 100
                      ? Colores.hecho
                      : widget.tarea.prioridad == 2
                          ? Colores.naranja
                          : Colores.eliminar,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.tarea.progreso == 100
                      ? 'Tarea Completada'
                      : widget.tarea.prioridad == 1
                          ? 'Baja'
                          : widget.tarea.prioridad == 2
                              ? 'Media'
                              : 'Alta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.tarea.prioridad == 1 ||
                            widget.tarea.progreso == 100
                        ? Colores.hecho
                        : widget.tarea.prioridad == 2
                            ? Colores.naranja
                            : Colores.eliminar,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Avatares y categoría
          Row(
            children: [
              // Avatares
              if (avatares.isNotEmpty)
                Row(
                  children: perfilesDestinatarios.map((perfil) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: FileImage(
                              avatares[perfilesDestinatarios.indexOf(perfil)],
                            ),
                            onBackgroundImageError: (_, __) {
                              print("Error al cargar la imagen del avatar");
                            },
                          ),
                          const SizedBox(
                              height:
                                  4), // Espaciado entre el avatar y el nombre
                          Text(
                            perfil.nombre, // Muestra el nombre del perfil
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Row(
                  children: List.generate(
                    widget.tarea.destinatario.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colores.fondo,
                            child: Icon(
                              Icons.person,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                              size: 16,
                            ),
                          ),
                          const SizedBox(
                              height:
                                  4), // Espaciado entre el avatar y el texto
                          Text(
                            "Usuario ${index + 1}", // Texto genérico si no hay avatar
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Espaciador para empujar la categoría hacia la mitad horizontal
              Spacer(),

              // Categoría
              Container(
                constraints: const BoxConstraints(
                    minWidth: 150), // Ancho mínimo para consistencia
                child: FutureBuilder(
                  future: obtenerCategoriaNombre(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Cargando categoría...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error al cargar categoría',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xFF${categoria.Color}"))
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.orden.isEven
                                ? Colores.texto.withOpacity(0.5)
                                : Colores.fondoAux.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          snapshot.data ?? categoria.nombre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.orden.isEven
                                ? Colores.texto
                                : Colores.fondoAux,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.tarea.progreso / 100,
                  backgroundColor: Colores.fondo,
                  color: widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${widget.tarea.progreso}%",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.orden.isEven ? Colores.texto : Colores.fondo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            "Descripción: ${widget.tarea.descripcion}",
            style: TextStyle(
              fontSize: 14,
              color: widget.orden.isEven ? Colores.texto : Colores.fondo,
            ),
          ),
        ],
      ),
    );
  }
}
