import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Inicio/seleccionPerfil.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/View/Ajustes/perfil.dart';
import 'package:smart_family/components/colores.dart';

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
              color: ColoresAjustes.texto,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColoresAjustes.fondo,
        automaticallyImplyLeading: false, // Elimina la flecha de "volver"
      ),
      backgroundColor: ColoresAjustes.fondo, // Fondo oscuro para el modo oscuro
      body: ListView(
        children: [
          // Sección del perfil
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color:
                  ColoresAjustes.fondoContenedores, // Fondo oscuro del perfil
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                // Aumentar el tamaño del contenedor
                height:
                    60, // Puedes ajustar este valor para mayor o menor altura
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        widget.perfil.FotoPerfil.isNotEmpty ? null : null,
                    child: widget.perfil.FotoPerfil.isEmpty
                        ? Text(
                            widget.perfil.Nombre[
                                0], // Mostrar la inicial si no hay imagen
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
                  title: Text(
                    widget.perfil.Nombre,
                    style: const TextStyle(color: Colores.texto, fontSize: 20),
                  ),
                  subtitle: Text(
                    widget.perfil.FechaNacimiento,
                    style: const TextStyle(color: ColoresAjustes.texto),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Esto asegura que el Row ocupe el mínimo espacio necesario
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Acción para el primer ícono (por ejemplo, el ícono de info)
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child:
                                  Perfil(perfil: widget.perfil,), // Cambia esto por la pantalla correspondiente
                            ),
                          );
                        },
                        child:
                            const Icon(Icons.info, color: ColoresAjustes.texto),
                      ),
                      const SizedBox(width: 8), // Espacio entre los íconos
                      GestureDetector(
                        onTap: () {
                          // Acción para el segundo ícono (por ejemplo, la flecha)
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: SeleccionPerfil(IdUsuario: widget.perfil.UsuarioId),
                            ),
                          );
                        },
                        child: const Icon(Icons.change_circle,
                            color: ColoresAjustes.texto),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Opciones de ajustes principales
          buildSettingsSection([
            _buildSettingItem(Icons.language, 'Idioma', 0),
            _buildSettingItem(Icons.accessibility, 'Accesibilidad', 1),
            _buildSettingItem(
                Icons.shield_rounded, 'Privacidad & Seguridad', 2),
            _buildSettingItem(Icons.notifications, 'Notificaciones', 3),
          ]),
          const SizedBox(height: 20), // Separador entre secciones
          // Otra sección de ajustes
          buildSettingsSection([
            _buildSettingItem(Icons.person, 'Cuenta', 20),
            _buildSettingItem(Icons.lock, 'Privacidad', 21),
            _buildSettingItem(Icons.chat, 'Chats', 23),
            _buildSettingItem(Icons.notifications, 'Notificaciones', 24),
            _buildSettingItem(Icons.data_usage, 'Almacenamiento y datos', 25),
          ]),
          const SizedBox(height: 20), // Separador entre secciones
          // Otra sección de ajustes
          buildSettingsSection([
            _buildSettingItem(Icons.help, 'Ayuda y Soporte', 30),
            _buildSettingItem(Icons.info_outline, 'Acerca de', 31)
          ]),
          const SizedBox(height: 20), // Separador entre secciones
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController:
              PageController(), // Cambia a PageController() si decides usarlo en el futuro
          pagina: 2,
          perfil: widget.perfil),
    );
  }

  // Método para crear las secciones de ajustes
  Widget buildSettingsSection(List<Widget> items) {
    return Card(
      color: ColoresAjustes.fondoContenedores,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  // Método para crear los ítems individuales de los ajustes
  Widget _buildSettingItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: ColoresAjustes.texto),
      title: Text(label, style: const TextStyle(color: ColoresAjustes.texto)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: ColoresAjustes.texto),
      onTap: () {
        // Acción al presionar
        switch (index) {
          case 0:
            break;
        }
      },
    );
  }
}
