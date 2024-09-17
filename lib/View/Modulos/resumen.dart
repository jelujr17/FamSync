// lib/View/resumen_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';

class ResumenScreen extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;

  const ResumenScreen(
      {super.key,
      required this.perfil,
      this.navigatorKey});

  @override
  ResumenScreenState createState() => ResumenScreenState();
}

class ResumenScreenState extends State<ResumenScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    );
  }
}
