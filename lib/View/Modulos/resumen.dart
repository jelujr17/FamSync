// lib/View/resumen_screen.dart

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart'; // Asegúrate de importar el archivo correcto

class ResumenScreen extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final int IdUsuario;
  final int Id;

  const ResumenScreen(
      {super.key,
      required this.IdUsuario,
      required this.Id,
      this.navigatorKey});

  @override
  ResumenScreenState createState() => ResumenScreenState();
}

class ResumenScreenState extends State<ResumenScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  late NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
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
                'Hola, Usuario ${widget.IdUsuario}!\n\n'
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
    );
  }
}
