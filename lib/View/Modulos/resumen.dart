// lib/View/resumen_screen.dart

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/navegacion.dart';

class ResumenScreen extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;

  const ResumenScreen({super.key, required this.perfil, this.navigatorKey});

  @override
  ResumenScreenState createState() => ResumenScreenState();
}

class ResumenScreenState extends State<ResumenScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  late NotchBottomBarController _bottomBarController;

  @override
  void initState() {
    super.initState();
    print("Perfil cargado: ${widget.perfil.FotoPerfil}"); // Para depuración

    _bottomBarController = NotchBottomBarController(index: 0);
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        automaticallyImplyLeading: false, // Esto elimina el botón de "atrás"
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido a la aplicación!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hola, Usuario ${widget.perfil.Nombre}!\n\n'
                'Esta es la pantalla de bienvenida donde puedes encontrar información general y acceder a otras funciones de la aplicación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: _pageController,
          pagina: 0,
          perfil: widget.perfil),
    );
  }
}
