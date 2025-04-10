
import 'dart:io';

import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoPerfilesEditar extends StatelessWidget {
  final List<Perfiles> perfiles;
  final List<int> perfilSeleccionado;
  final Function(int) onPerfilSeleccionado;

  const CampoPerfilesEditar({
    super.key,
    required this.perfiles,
    required this.perfilSeleccionado,
    required this.onPerfilSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.fondoAux, // Fondo fondoAux para toda la sección
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(12), // Espaciado interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del apartado
            const Text(
              'Producto visible para los siguientes perfiles:',
              style: TextStyle(
                color: Colores.texto, // Texto texto
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Espaciado entre el título y la lista
            // Lista de perfiles
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Evita conflictos de scroll
              itemCount: perfiles.length,
              itemBuilder: (context, index) {
                final perfil = perfiles[index];

                return ListTile(
                  title: Text(
                    perfil.Nombre,
                    style: const TextStyle(
                      color: Colores.texto,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  leading: perfil.FotoPerfil.isNotEmpty
                      ? FutureBuilder<File>(
                          future: ServicioPerfiles()
                              .obtenerImagen(context, perfil.FotoPerfil),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Icon(Icons.error);
                            } else if (!snapshot.hasData) {
                              return const Icon(Icons.image_not_supported);
                            } else {
                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: FileImage(snapshot.data!),
                                  ),
                                  if (perfilSeleccionado.contains(perfil.Id))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.check_circle,
                                          color: Colores.texto, size: 30),
                                    ),
                                ],
                              );
                            }
                          },
                        )
                      : const Icon(Icons.image_not_supported),
                  tileColor: perfilSeleccionado.contains(perfil.Id)
                      ? Colores.fondoAux
                      : null,
                  onTap: () {
                    onPerfilSeleccionado(perfil.Id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}