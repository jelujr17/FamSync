import 'dart:io';

import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CampoPerfilesCrearEvento extends StatelessWidget {
  final List<Perfiles> perfiles;
  final List<String> perfilSeleccionado;
  final Function(String) onPerfilSeleccionado;

  CampoPerfilesCrearEvento({
    super.key,
    required this.perfiles,
    required this.perfilSeleccionado,
    required this.onPerfilSeleccionado,
  });
  final user = FirebaseAuth.instance.currentUser;

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
              'Perfiles destinatarios',
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
                    perfil.nombre,
                    style: const TextStyle(
                      color: Colores.texto,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  leading: perfil.FotoPerfil.isNotEmpty
                      ? FutureBuilder<File?>(
                          future: ServicioPerfiles().getFotoPerfil(
                              user!.uid,
                              perfil
                                  .PerfilID), // Replace 'perfil.userId' with the correct user ID property
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Icon(Icons.error);
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Icon(Icons.image_not_supported);
                            } else {
                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: FileImage(snapshot.data!),
                                  ),
                                  if (perfilSeleccionado
                                      .contains(perfil.PerfilID))
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
                  tileColor: perfilSeleccionado.contains(perfil.PerfilID)
                      ? Colores.fondoAux
                      : null,
                  onTap: () {
                    onPerfilSeleccionado(perfil.PerfilID);
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
