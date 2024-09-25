import 'dart:io';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart';

class Ajustes extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;

  const Ajustes({super.key, required this.perfil, this.navigatorKey});

  @override
  AjustesState createState() => AjustesState();
}

class AjustesState extends State<Ajustes> {
  bool notificaciones = true; // Estado para controlar las notificaciones
  final PageController _pageController = PageController(initialPage: 2);
  late NotchBottomBarController _bottomBarController;
  bool modoOscuro = false; // Estado para controlar el modo oscuro

  // Controlador de texto para la búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bottomBarController = NotchBottomBarController(index: 2);
    cargarPreferenciasNotificaciones();
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _pageController.dispose();
    _searchController.dispose(); // Asegúrate de liberar el controlador
    super.dispose();
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colores.fondo, // Cambia a tu color deseado

        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colores.fondo, // Cambia a tu color deseado

              title: const Text('Ajustes'),
              pinned: false,
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Barra de búsqueda
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colores.texto, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colores.botonesSecundarios, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // El resto de la lista de ajustes
                _buildSectionHeader('Preferencias de la app'),

                _buildSettingItem(Icons.language, 'Idioma'),
                _buildSettingItem(Icons.security, 'Privacidad & Seguridad'),
                _buildSettingItemMode(
                  Icon(modoOscuro ? Icons.light_mode : Icons.dark_mode),
                  'Modo ${modoOscuro ? "claro" : "oscuro"}',
                ),
                _buildSettingItemNotificaciones(
                  Icon(notificaciones
                      ? Icons.notifications
                      : Icons.notifications_off),
                  'Notificaciones',
                  notificaciones,
                ),
                _buildSectionHeader(''),

                _buildSectionHeader('Cuenta'),
                _buildSettingItem(Icons.lock, 'Cambiar Contraseña'),
                _buildSettingItem(Icons.edit, 'Cambiar Correo'),
                _buildSettingItem2(Icons.delete, 'Eliminar Cuenta'),

                _buildSectionHeader(''),

                _buildSectionHeader('Soporte'),
                _buildSettingItem(Icons.help_outline, 'Ayuda & Soporte'),
                _buildSettingItem(Icons.info_outline, 'Acerca de'),
                _buildSectionHeader(''),

                _buildSectionHeader(''),

                _buildSectionHeader(''),
              ]),
            ),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: CustomBottomNavBar(
          pageController: _pageController,
          pagina: 2,
          perfil: widget.perfil,
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
            fontWeight: FontWeight.bold, fontSize: 12, color: Colores.texto),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
      ),
    );
  }

  Widget _buildSettingItemMode(Icon icon, String label) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
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
      ),
    );
  }

  Widget _buildSettingItem2(IconData icon, String label) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        textColor: Colores.eliminar,
      ),
    );
  }

  Widget _buildSettingItemNotificaciones(
      Icon icon, String label, bool valorActual) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
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
          activeColor: Colores.botonesSecundarios,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
    );
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

  Future<dynamic> mostrarDialogoConfirmacion(bool modoOscuro) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content:
              const Text('¿Estás seguro de que deseas realizar esta acción?'),
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
