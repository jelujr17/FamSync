import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/Editar_Perfil.dart';
import 'package:famsync/components/colores.dart';

class Perfil extends StatefulWidget {
  final Perfiles perfil;
  final GlobalKey<NavigatorState>? navigatorKey;

  const Perfil({super.key, required this.perfil, this.navigatorKey});

  @override
  PerfilState createState() => PerfilState();
}

class PerfilState extends State<Perfil> {
  final PageController _pageController = PageController(initialPage: 2);

  @override
  void initState() {
    super.initState();
    print("Perfil cargado: ${widget.perfil.FotoPerfil}"); // Para depuración
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      widget.perfil.FotoPerfil.isNotEmpty ? null : null,
                  child: widget.perfil.FotoPerfil.isEmpty
                      ? Text(
                          widget.perfil
                              .Nombre[0], // Mostrar la inicial si no hay imagen
                          style: const TextStyle(
                            color: Colores.texto,
                            fontSize: 30,
                          ),
                        )
                      : FutureBuilder<File>(
                          future: ServicioPerfiles()
                              .obtenerImagen(context, widget.perfil.FotoPerfil),
                          builder: (BuildContext context,
                              AsyncSnapshot<File> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Mientras la imagen se está descargando, mostramos un indicador de carga
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              print("error al obtener la imagen");
                              // Si hay un error al cargar la imagen, mostramos un ícono de error o similar
                              return const Icon(Icons.error,
                                  color: Colores.texto);
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              print("imagen descargada");
                              // Si la imagen se ha descargado correctamente, devolvemos un CircleAvatar con la imagen
                              return CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(
                                    snapshot.data!), // Mostrar la imagen
                              );
                            } else {
                              // Si no hay datos, mostramos un espacio vacío o algún fallback
                              return const Icon(Icons.person,
                                  color: Colores.texto);
                            }
                          },
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: EditarPerfilScreen(
                            perfil: widget.perfil,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.perfil.Nombre, // Reemplazar con el nombre del perfil
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      
    );
  }
}
