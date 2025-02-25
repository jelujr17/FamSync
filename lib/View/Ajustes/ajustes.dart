import 'dart:io';
import 'package:famsync/View/Ajustes/Preferencias/preferencias.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:famsync/View/Ajustes/perfil.dart';
import 'package:famsync/components/colores.dart';

class Ajustes extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;

  const Ajustes({super.key, required this.perfil, this.navigatorKey});

  @override
  AjustesState createState() => AjustesState();
}

class AjustesState extends State<Ajustes> {
  bool notificaciones = true;
  bool modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: Colores.texto,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colores.fondo,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colores.fondo,
      body: ListView(
        children: [
          // Sección del perfil
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colores.fondoAux,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                height: 80,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        widget.perfil.FotoPerfil.isNotEmpty ? null : null,
                    child: widget.perfil.FotoPerfil.isEmpty
                        ? Text(
                            widget.perfil.Nombre[0],
                            style: const TextStyle(
                              color: Colores.texto,
                              fontSize: 30,
                            ),
                          )
                        : FutureBuilder<File>(
                            future: ServicioPerfiles()
                                .obtenerImagen(widget.perfil.FotoPerfil),
                            builder: (BuildContext context,
                                AsyncSnapshot<File> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(
                                  Icons.error,
                                  color: Colores.texto,
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
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
                    widget.perfil.Nombre,
                    style: const TextStyle(
                      color: Colores.texto,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    widget.perfil.FechaNacimiento,
                    style: const TextStyle(
                      color: Colores.texto,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: Perfil(perfil: widget.perfil),
                            ),
                          );
                        },
                        child: const Icon(Icons.info, color: Colores.texto),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: SeleccionPerfil(
                                  IdUsuario: widget.perfil.UsuarioId),
                            ),
                          );
                        },
                        child: const Icon(Icons.change_circle,
                            color: Colores.texto),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Sección de ajustes principales
          buildSettingsSection([
            _buildSettingItem(Icons.accessibility, 'Accesibilidad', 1),
            _buildSettingItem(
                Icons.shield_rounded, 'Privacidad & Seguridad', 2),
            _buildSettingItem(Icons.notifications, 'Notificaciones', 3),
          ]),
          const SizedBox(height: 20),
          // Otra sección de ajustes
          buildSettingsSection([
            _buildSettingItem(Icons.person, 'Cuenta', 4),
            _buildSettingItem(Icons.settings, 'Preferencias', 5),
            _buildSettingItem(Icons.lock, 'Privacidad', 6),
            _buildSettingItem(Icons.data_usage, 'Almacenamiento y datos', 7),
          ]),
          const SizedBox(height: 20),
          // Sección de ayuda
          buildSettingsSection([
            _buildSettingItem(Icons.info, 'Ayuda y Soporte', 8),
          ]),
          const SizedBox(height: 20),
        ],
      ),
      
    );
  }

  // Método para crear las secciones de ajustes
  Widget buildSettingsSection(List<Widget> items) {
    return Card(
      color: Colores.fondoAux,
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  // Método para crear los ítems individuales de los ajustes
  Widget _buildSettingItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: Colores.texto),
      title: Text(
        label,
        style: const TextStyle(
          color: Colores.texto,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colores.texto),
      onTap: () {
        // Acción al presionar
        switch (index) {
         
          case 5:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const Preferencias(),
              ),
            );
            break;
        }
      },
    );
  }
}
