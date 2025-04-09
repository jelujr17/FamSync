import 'package:famsync/Model/categorias.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Editar_ID_Categoria.dart';
import 'package:famsync/View/Modulos/Tareas/Ver_ID/Editar_ID_Prioridad.dart';
import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:provider/provider.dart';

class EditarTareaDialog extends StatefulWidget {
  final Tareas tarea;
  final Function(String, String, int?, int) onTareaEditada;
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

  @override
  void initState() {
    nombreController.text = widget.tarea.Nombre;
    descripcionController.text = widget.tarea.Descripcion;
    prioridad = widget.tarea.Prioridad;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoriasProvider.cargarCategorias(context, widget.perfil.UsuarioId, 5);
    });
    super.initState();
  }

  @override
  Widget build(context) {
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: false);
    categoriasDisponibles = categoriasProvider.categorias;
    nombresCategoria = categoriasDisponibles.map((e) => e.Nombre).toList();
    categoriaSeleccionada = categoriasDisponibles
        .firstWhere((element) => element.Id == widget.tarea.Categoria)
        .Nombre;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.grisOscuro.withOpacity(0.95), // Fondo del diálogo
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colores.amarillo.withOpacity(0.3),
              offset: const Offset(0, 30),
              blurRadius: 60,
            ),
            const BoxShadow(
              color: Colores.amarillo,
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
                      color: Colores.amarillo,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo para el nombre de la tarea
                  TextFormField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Tarea',
                      labelStyle: const TextStyle(
                          fontSize: 16, color: Colores.amarillo),
                      hintText: 'Ingresa un nombre para la Tarea',
                      hintStyle: const TextStyle(color: Colores.amarillo),
                      prefixIcon: const Icon(Icons.shopping_bag,
                          color: Colores.amarillo),
                      filled: true,
                      fillColor: Colores.negro,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none, // Sin borde inicial
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: Colores.negro, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colores.amarillo, width: 2),
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
                            Colores.amarillo), // Cambia el color del texto aquí
                  ),
                  const SizedBox(height: 16),

                  // Campo para la descripción de la tarea
                  TextFormField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción de la Tarea',
                      labelStyle: const TextStyle(
                          fontSize: 16, color: Colores.amarillo),
                      hintText: 'Ingresa una descripción para la Tarea',
                      hintStyle: const TextStyle(color: Colores.amarillo),
                      prefixIcon: const Icon(Icons.description,
                          color: Colores.amarillo),
                      filled: true,
                      fillColor: Colores.negro,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none, // Sin borde inicial
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: Colores.negro, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colores.amarillo, width: 2),
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
                      color: Colores.amarillo, // Cambia el color del texto aquí
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
                            color: Colores.negro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Navigator.canPop(this.context)) {
                            int? categoriaAux = categoriasDisponibles
                                .firstWhere(
                                  (element) =>
                                      element.Nombre == categoriaSeleccionada,
                                  orElse: () => Categorias(
                                      Id: 0,
                                      Nombre: "Sin Categoría",
                                      IdModulo: 0,
                                      Color: '000000',
                                      IdUsuario: 0),
                                )
                                .Id;
                                if(categoriaAux == 0){
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
                            color: Colores.amarillo,
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
