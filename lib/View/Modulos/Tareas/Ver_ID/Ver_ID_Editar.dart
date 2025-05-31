import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Editar_ID_Categoria.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Editar_ID_Prioridad.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:provider/provider.dart';

class EditarTareaDialog extends StatefulWidget {
  final Tareas tarea;
  final Function(String, String, String?, int) onTareaEditada;
  final BuildContext context;
  final Perfiles perfil;

  const EditarTareaDialog({
    super.key,
    required this.tarea,
    required this.onTareaEditada,
    required this.context,
    required this.perfil,
  });

  @override
  _EditarTareaDialogState createState() => _EditarTareaDialogState();
}

class _EditarTareaDialogState extends State<EditarTareaDialog> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  List<Categorias> categoriasDisponibles = [];
  String? categoriaSeleccionada;
  List<String> nombresCategoria = [];
  int prioridad = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    nombreController.text = widget.tarea.nombre;
    descripcionController.text = widget.tarea.descripcion;
    prioridad = widget.tarea.prioridad;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(user!.uid, widget.perfil.PerfilID);
    });
    super.initState();
  }

  @override
  Widget build(context) {
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasDisponibles = categoriasProvider.categorias;
    nombresCategoria = categoriasDisponibles.map((e) => e.nombre).toList();
    categoriaSeleccionada = categoriasDisponibles
        .firstWhere(
            (element) => element.CategoriaID == widget.tarea.CategoriaID)
        .nombre;
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título del diálogo
                  Text(
                    'Editar Tarea',
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
                      labelText: 'nombre de la Tarea',
                      labelStyle:
                          const TextStyle(fontSize: 16, color: Colores.texto),
                      hintText: 'Ingresa un nombre para la Tarea',
                      hintStyle: const TextStyle(color: Colores.texto),
                      prefixIcon:
                          const Icon(Icons.shopping_bag, color: Colores.texto),
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
                        color: Colores.texto), // Cambia el color del texto aquí
                  ),
                  const SizedBox(height: 16),

                  // Campo para la descripción de la tarea
                  TextFormField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción de la Tarea',
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
                  CampoCategoriaEditarTarea(
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
                  const SizedBox(height: 20),
                  CampoPrioridadEditarTarea(
                    prioridadSeleccionada: prioridad,
                    onPrioridadSeleccionada: (value) {
                      prioridad = value;
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
                          Navigator.of(this.context).pop(); // Cerrar el diálogo
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
                          if (Navigator.canPop(this.context)) {
                            String? categoriaAux = categoriasDisponibles
                                .firstWhere(
                                  (element) =>
                                      element.nombre == categoriaSeleccionada,
                                  orElse: () => Categorias(
                                      CategoriaID: "0",
                                      Color: '000000',
                                      nombre: "Sin Categoría",
                                      PerfilID: "0"),
                                )
                                .CategoriaID;
                            if (categoriaAux == 0) {
                              categoriaAux = null;
                            }
                            widget.onTareaEditada(
                                nombreController.text,
                                descripcionController.text,
                                categoriaAux,
                                prioridad);
                          }
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
    );
  }
}
