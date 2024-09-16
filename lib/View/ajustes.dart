// ignore_for_file: avoid_print, non_constant_identifier_names, deprecated_member_use
import 'dart:io';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart';
import 'package:url_launcher/url_launcher.dart';

class Ajustes extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final int IdUsuario;
  final int Id;

  const Ajustes(
      {super.key,
      required this.IdUsuario,
      required this.Id,
      this.navigatorKey});

  @override
  AjustesState createState() => AjustesState();
}

class AjustesState extends State<Ajustes> {
  final PageController _pageController = PageController(initialPage: 2);
  late NotchBottomBarController _controller;
  bool modoOscuro = false; // Estado para controlar el modo oscuro
  bool notificaciones = true; // Estado para controlar las notificaciones
  String modo = "oscuro";

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 2);

    cargarPreferenciasNotificaciones();
  }

  // Método para cargar la configuración de notificaciones
  void cargarPreferenciasNotificaciones() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificaciones = prefs.getBool('Notificaciones') ?? true;
    });
  }

  // Método para guardar las preferencias de notificaciones
  void guardarPreferenciasNotificaciones() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('Notificaciones', notificaciones);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: modoOscuro ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ajustes'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSectionHeader('Preferencias de la app'),
              _buildSettingItem(Icons.language, 'Idioma'),
              _buildSettingItemMode(
                  Icon(modoOscuro ? Icons.light_mode : Icons.dark_mode),
                  'Modo ${modoOscuro ? "claro" : "oscuro"}'),
              _buildSettingItem(Icons.security, 'Privacidad & Seguridad'),
              _buildSettingItemNotificaciones(
                  Icon(notificaciones
                      ? Icons.notifications
                      : Icons.notifications_off),
                  'Notificaciones',
                  notificaciones),
              _buildSettingItem2(
                  const Icon(Icons.clear, color: Colors.red), 'Borrar Cache'),
              _buildSectionHeader('Conexiones'),
              _buildSettingItem(Icons.link, 'Cuentas vinculadas'),
              _buildSettingItem(
                  Icons.cloud_upload, 'Sincronización y Copias de seguridad'),
              _buildSectionHeader('Seguridad'),
              _buildSettingItem(Icons.lock, 'Cambiar Contraseña'),
              _buildSectionHeader('Soporte'),
              _buildSettingItem(Icons.help_outline, 'Ayuda & Soporte'),
              _buildSettingItem(Icons.info_outline, 'Acerca de'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () async {
        if (label == 'Privacidad & Seguridad') {
          _openAppSettings();
        }
      },
    );
  }

  Widget _buildSettingItemMode(Icon icon, String label) {
    return ListTile(
      leading: icon,
      title: Text(label),
      onTap: () async {
        bool confirmacion = await mostrarDialogoConfirmacion(modoOscuro);
        if (confirmacion) {
          setState(() {
            modoOscuro = !modoOscuro;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('Dark_Mode', modoOscuro);
        }
      },
    );
  }

  Widget _buildSettingItemNotificaciones(
      Icon icon, String label, bool valorActual) {
    return ListTile(
      leading: icon,
      title: Text(label),
      trailing: Switch(
        value: valorActual,
        onChanged: (value) {
          setState(() {
            notificaciones = value;
          });
          guardarPreferenciasNotificaciones();
        },
        activeColor: Colores
            .botonesSecundarios, // Color del switch cuando está encendido
        inactiveThumbColor: Colors.grey, // Color del botón cuando está apagado
        inactiveTrackColor:
            Colors.grey.shade300, // Color de la pista cuando está apagado
      ),
    );
  }

  Widget _buildSettingItem2(Widget icon, String label) {
    return ListTile(
      leading: icon,
      title: Text(
        label,
        style: TextStyle(
          color: label == 'Borrar Cache' ? Colors.red : null,
        ),
      ),
      onTap: () {
        if (label == 'Borrar Cache') {
          borrarContenidoDirectorioDocuments();
        }
      },
    );
  }

  void _openAppSettings() async {
    const url = 'app-settings:';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir la configuración de la aplicación.';
    }
  }

  Future<void> borrarContenidoDirectorioDocuments() async {
    try {
      Directory directorioDocumentos = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> elementos = directorioDocumentos.listSync();

      for (var elemento in elementos) {
        if (elemento is File) {
          await elemento.delete();
        } else if (elemento is Directory) {
          await elemento.delete(recursive: true);
        }
      }
      print('Contenido del directorio Documents eliminado correctamente');
    } catch (error) {
      print('Error al borrar el contenido del directorio Documents: $error');
    }
  }

  Future<bool> IsDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('Dark_Mode');
    return darkMode ?? false;
  }

  Future<dynamic> mostrarDialogoConfirmacion(bool modoOscuro) async {
    String modo = modoOscuro ? "claro" : "oscuro";
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text('¿Estás seguro de que deseas cambiar al modo $modo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
