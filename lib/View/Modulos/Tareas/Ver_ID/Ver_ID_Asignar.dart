import 'dart:io';

import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:provider/provider.dart';

class AsignarTareaDialog extends StatefulWidget {
  final Tareas tarea;
  final Function(List<int>) onAsignarGuardado;
  final Perfiles perfil;
  final BuildContext context;

  const AsignarTareaDialog({
    super.key,
    required this.tarea,
    required this.onAsignarGuardado,
    required this.perfil,
    required this.context,
  });

  @override
  _AsignarTareaDialogState createState() => _AsignarTareaDialogState();
}

class _AsignarTareaDialogState extends State<AsignarTareaDialog> {
  List<int> perfilesSeleccionados = [];
  List<Perfiles> perfilesDisponibles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarPerfiles();
  }

  Future<void> cargarPerfiles() async {
    final perfilesProvider =
        Provider.of<PerfilesProvider>(context, listen: false);

    // Cargar perfiles desde el proveedor
    await perfilesProvider.cargarPerfiles(context, widget.perfil.UsuarioId);
    setState(() {
      perfilesDisponibles = perfilesProvider.perfiles; // Actualizar la lista
      perfilesSeleccionados =
          widget.tarea.Destinatario; // Inicializar seleccionados
      isLoading = false; // Finalizar la carga
    });
  }

  @override
  Widget build(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6, // Ajustar ancho
        decoration: BoxDecoration(
          color: Colores.grisOscuro.withOpacity(0.95), // Fondo del diálogo
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colores.amarillo.withOpacity(0.3),
              offset: const Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reducir padding
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Mostrar cargando
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título del diálogo
                    Text(
                      'Asignar Perfiles',
                      style: TextStyle(
                        color: Colores.amarillo,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Reducir tamaño de fuente
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de perfiles con Checkbox
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.3, // Limitar altura
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: perfilesDisponibles.length,
                        itemBuilder: (context, index) {
                          final perfil = perfilesDisponibles[index];

                          return Card(
                            color: perfilesSeleccionados.contains(perfil.Id)
                                ? Colores.negro
                                : Colores.grisOscuro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: perfil.FotoPerfil.isNotEmpty
                                  ? FutureBuilder<File>(
                                      future: ServicioPerfiles().obtenerImagen(
                                          context, perfil.FotoPerfil),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else if (!snapshot.hasData) {
                                          return const Icon(
                                              Icons.image_not_supported);
                                        } else {
                                          return CircleAvatar(
                                            radius:
                                                16, // Reducir tamaño del avatar
                                            backgroundImage:
                                                FileImage(snapshot.data!),
                                          );
                                        }
                                      },
                                    )
                                  : const Icon(Icons.image_not_supported),
                              title: Text(
                                perfil.Nombre,
                                style: const TextStyle(
                                  color: Colores.amarillo,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14, // Reducir tamaño de fuente
                                ),
                              ),
                              trailing:
                                  perfilesSeleccionados.contains(perfil.Id)
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colores.naranja,
                                        )
                                      : null,
                              onTap: () {
                                setState(() {
                                  if (perfilesSeleccionados
                                      .contains(perfil.Id)) {
                                    perfilesSeleccionados.remove(perfil.Id);
                                  } else {
                                    perfilesSeleccionados.add(perfil.Id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botones para guardar o cancelar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(this.context).pop(); // Cerrar el diálogo
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colores.amarillo,
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Reducir tamaño de fuente
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (Navigator.canPop(this.context)) {
                              widget.onAsignarGuardado(perfilesSeleccionados);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colores.naranja, width: 2),
                            ),
                            child: Text(
                              "Asignar",
                              style: TextStyle(
                                color: Colores.naranja,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
