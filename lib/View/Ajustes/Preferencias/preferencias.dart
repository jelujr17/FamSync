import 'package:flutter/material.dart';
import 'package:famsync/components/colores.dart';

class Preferencias extends StatelessWidget {
  const Preferencias({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: Colores.fondo,
      ),
      backgroundColor: Colores.fondo,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: Colores.texto),
            title: const Text('Idioma', style: TextStyle(color: Colores.texto)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colores.texto),
            onTap: () {
              // Navegar a la configuración de idioma
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colores.texto),
            title: const Text('Modo Oscuro', style: TextStyle(color: Colores.texto)),
            trailing: Switch(
              value: true, // Cambiar según estado
              onChanged: (value) {
                // Lógica para cambiar tema
              },
            ),
          ),
        ],
      ),
    );
  }
}
