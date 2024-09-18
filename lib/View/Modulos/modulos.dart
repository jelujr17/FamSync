import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Modulos/calendario.dart';
import 'package:smart_family/View/navegacion.dart';

class Modulos extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;

  const Modulos({super.key, this.navigatorKey, required this.perfil});

  @override
  ModulosState createState() => ModulosState();
}

class ModulosState extends State<Modulos> {
  final PageController _pageController = PageController(initialPage: 1);
  late NotchBottomBarController _bottomBarController;

  @override
  void initState() {
    super.initState();
    _bottomBarController = NotchBottomBarController(index: 1);
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> modulos = [
    {'titulo': 'Calendario', 'icono': Icons.calendar_today, 'ruta': 0},
    {'titulo': 'Almacén', 'icono': Icons.shopping_cart, 'ruta': 1},
    {'titulo': 'Medicina', 'icono': Icons.medical_services, 'ruta': 2},
    {'titulo': 'Ropa', 'icono': Icons.checkroom, 'ruta': 3},
    {'titulo': 'Tareas', 'icono': Icons.task, 'ruta': 4},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulos'),
        automaticallyImplyLeading: false, // Esto elimina el botón de "atrás"
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Aumentar el número de columnas
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio:
              1, // Ajustar la proporción de alto-ancho de cada botón
        ),
        itemCount: modulos.length,
        itemBuilder: (context, index) {
          final modulo = modulos[index];
          return GestureDetector(
            onTap: () {
              if (modulo['ruta'] == 0) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: Calendario(perfil: widget.perfil),
                  ),
                );
              }
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(modulo['icono'],
                      size: 40, color: Colors.blueAccent), // Icono más pequeño
                  const SizedBox(
                      height: 5), // Menor espacio entre icono y texto
                  Text(modulo['titulo'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold)), // Texto más pequeño
                ],
              ),
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: _pageController,
          controller: _bottomBarController,
          perfil: widget.perfil),
    );
  }
}
