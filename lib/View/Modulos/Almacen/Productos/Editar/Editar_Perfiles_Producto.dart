
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
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: perfiles.length > 1
            ? perfiles.length - 1
            : 0, // Restamos 1 si hay más de un perfil
        itemBuilder: (context, index) {
          final perfil = perfiles[index + 1];

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
                    future: ServicioPerfiles().obtenerImagen(context, perfil.FotoPerfil),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    color: Colors.green),
                              ),
                          ],
                        );
                      }
                    },
                  )
                : const Icon(Icons.image_not_supported),
            tileColor: perfilSeleccionado.contains(perfil.Id)
                ? Colores.principal.withOpacity(0.2)
                : null,
            onTap: () {
              onPerfilSeleccionado(perfil.Id);
            },
          );
        },
      ),
    );
  }
}