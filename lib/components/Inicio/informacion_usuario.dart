import 'dart:io';

import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.nombre,
    required this.fecha,
    required this.perfil,
  });

  final String nombre, fecha;
  final Perfiles perfil;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: perfil.FotoPerfil.isNotEmpty ? null : null,
        child: perfil.FotoPerfil.isEmpty
            ? Text(
                perfil.Nombre[0],
                style: const TextStyle(
                  color: Colores.texto,
                  fontSize: 30,
                ),
              )
            : FutureBuilder<File>(
                future: ServicioPerfiles().obtenerImagen(perfil.FotoPerfil),
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Icon(
                      Icons.error,
                      color: Colores.texto,
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(snapshot.data!),
                    );
                  } else {
                    return const Icon(
                      Icons.person,
                      color: Colores.texto,
                    );
                  }
                },
              ),
      ),
      title: Text(
        nombre,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        fecha,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
